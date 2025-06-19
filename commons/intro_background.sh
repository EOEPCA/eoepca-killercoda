#!/bin/bash
#Script to set pre-requisites for EOEPCA components
echo setting-up your environment... wait till this setup terminates before starting the tutorial >> /tmp/killercoda_setup.log
if [[ -e /tmp/assets/localdns ]]; then
  #DNS-es for dependencies
  echo "setting local dns..." >> /tmp/killercoda_setup.log
  WEBSITES="`tr -d '\n' < /tmp/assets/localdns`"
  echo "172.30.1.2 $WEBSITES" >> /etc/hosts
  kubectl get -n kube-system configmap/coredns -o yaml > kc.yml
  sed -i "s|ready|ready\n        hosts {\n          172.30.1.2 $WEBSITES\n          fallthrough\n        }|" kc.yml
  kubectl apply -f kc.yml && rm kc.yml && kubectl rollout restart -n kube-system deployment/coredns
fi
if [[ -e /tmp/assets/gomplate.7z ]]; then
  echo "installing gomplate..." >> /tmp/killercoda_setup.log
  #Gomplate is a dependency of the deployment tool
  #Installing it from local instead then remote for speed
  #curl -s -S -L -o /usr/local/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v4.3.0/gomplate_linux-amd64 && chmod +x /usr/local/bin/gomplate
  mkdir -p /usr/local/bin/ && 7z x /tmp/assets/gomplate.7z -o/usr/local/bin/ && chmod +x /usr/local/bin/gomplate
fi
if [[ -e /tmp/assets/nginxingress ]]; then
  #Installing Ingress (basic)
  echo installing nginx ingress... >> /tmp/killercoda_setup.log
  helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --create-namespace \
    --set controller.hostNetwork=true
fi
if [[ -e /tmp/assets/apisix ]]; then
  # Install apisix
  echo "installing apisix ingress..." >> /tmp/killercoda_setup.log
  helm repo add apisix https://charts.apiseven.com
  helm repo update apisix

  helm upgrade -i apisix apisix/apisix \
    --version 2.9.0 \
    --namespace ingress-apisix --create-namespace \
    --set securityContext.runAsUser=0 \
    --set hostNetwork=true \
    --set service.http.containerPort=80 \
    --set apisix.ssl.containerPort=443 \
    --set etcd.replicaCount=1 \
    --set apisix.enableIPv6=false \
    --set apisix.enableServerTokens=false \
    --set ingress-controller.enabled=true
fi
if [[ -e /tmp/assets/killercodaproxy ]]; then
  #Use an NGinx proxy to force the Host and replace the links to allow most applciations
  #to work with killercoda proxy
  echo configuring proxy for killercoda external access... >> /tmp/killercoda_setup.log
  [[ -e /tmp/apt-is-updated ]] || { apt-get update -y; touch /tmp/apt-is-updated; }
  #Install nginx with substitution mode
  apt-get install -y nginx libnginx-mod-http-subs-filter
  #write nginx configuration
  cat <<EOF >/etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
  worker_connections 768;
  # multi_accept on;
}

http {
  access_log /dev/null;
  gzip on;
EOF
  #All the proxy redirects must be placed into all the proxied sites, otherwise cross-site
  #redirections like the ones done by OPA will not work...
  echo -n "" > /tmp/assets/killercodaproxy_redirects
  while read port dest types; do
    echo "         proxy_redirect http://$dest `sed -e "s/PORT/$port/g" /etc/killercoda/host`;" >> /tmp/assets/killercodaproxy_redirects
  done < /tmp/assets/killercodaproxy
  while read port dest types; do
cat <<EOF>>/etc/nginx/nginx.conf
    server {

        listen       $port;

        location / {
         proxy_pass  http://$dest;
         proxy_set_header   Host             $dest:80;
         proxy_set_header Accept-Encoding "";
EOF
    cat /tmp/assets/killercodaproxy_redirects >> /etc/nginx/nginx.conf
    [[ "$types" != "NONE" && "$types" != "'NONE'" ]] && cat <<EOF>>/etc/nginx/nginx.conf
         subs_filter http://$dest  `sed -e "s/PORT/$port/g" /etc/killercoda/host`;
         subs_filter $dest  `sed -e "s/PORT/$port/g" -e "s|^https://||" /etc/killercoda/host`;
         subs_filter_types ${types//\'/};
EOF
cat <<EOF>>/etc/nginx/nginx.conf
        }
    }
EOF
  done < /tmp/assets/killercodaproxy
echo "}" >> /etc/nginx/nginx.conf
  #restart nginx
  service nginx restart
fi
if [[ -e /tmp/assets/minio.7z ]]; then
  #Installing Minio (basic)
  echo installing object storage...  >> /tmp/killercoda_setup.log
  ### Prerequisite: minio
  #We have this locally installed for speed
  #wget -q https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio && chmod +x /usr/local/bin/minio
  #wget -q https://dl.min.io/client/mc/release/linux-amd64/mc -O  /usr/local/bin/mc && chmod +x /usr/local/bin/mc
  mkdir -p /usr/local/bin/ && 7z x /tmp/assets/minio.7z -o/usr/local/bin/ && chmod +x /usr/local/bin/mc /usr/local/bin/minio
  mkdir -p ~/minio && MINIO_ROOT_USER=eoepca MINIO_ROOT_PASSWORD=eoepcatest nohup minio server --quiet ~/minio &>/dev/null &
  sleep 1
  while ! mc config host add minio-local http://minio.eoepca.local:9000/ eoepca eoepcatest; do sleep 1; done
  mkdir -p ~/.eoepca && echo 'export S3_ENDPOINT="http://minio.eoepca.local:9000/"
export S3_ACCESS_KEY="eoepca"
export S3_SECRET_KEY="eoepcatest"
export S3_REGION="us-east-1"' >> ~/.eoepca/state
fi
if [[ -e /tmp/assets/miniobuckets ]]; then
  BUCKETS="`tr -d '\n' < /tmp/assets/miniobuckets`"
  echo "creating object storage buckets: $BUCKETS..."  >> /tmp/killercoda_setup.log
  for bkt in $BUCKETS; do
    mc mb minio-local/$bkt
  done
fi
if [[ -e /tmp/assets/readwritemany ]]; then
  ### Prerequisites: readwritemany StorageClass
  echo enabling ReadWriteMany StorageClass..  >> /tmp/killercoda_setup.log
  kubectl apply -f https://raw.githubusercontent.com/EOEPCA/deployment-guide/refs/heads/main/docs/prerequisites/hostpath-provisioner.yaml
  echo 'export STORAGE_CLASS="standard"'>>~/.eoepca/state
fi
if [[ -e /tmp/assets/ignoreresrequests ]]; then
  ### Avoid applyiing resource limits, otherwise Clarissian will not work as limits are hardcoded in there...
  ### THIS IS JUST FOR DEMO! DO NOT DO THIS PART IN PRODUCTION!
  echo setting resource limits...  >> /tmp/killercoda_setup.log
  kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.18.2/deploy/gatekeeper.yaml
  cat <<EOF | kubectl apply -f -
apiVersion: mutations.gatekeeper.sh/v1
kind: Assign
metadata:
  name: relieve-resource-pods
spec:
  applyTo:
  - groups: [""]
    kinds: ["Pod"]
    versions: ["v1"]
  match:
    scope: Namespaced
    kinds:
      - apiGroups: [ "*" ]
        kinds: [ "Pod" ]
  location: "spec.containers[name:*].resources.requests"
  parameters:
    assign:
      value:
        cpu: "0"
        memory: "0"
---
apiVersion: mutations.gatekeeper.sh/v1
kind: Assign
metadata:
  name: relieve-resource-inits
spec:
  applyTo:
  - groups: [""]
    kinds: ["Pod"]
    versions: ["v1"]
  match:
    scope: Namespaced
    kinds:
      - apiGroups: [ "*" ]
        kinds: [ "Pod" ]
  location: "spec.initContainers[name:*].resources.requests"
  parameters:
    assign:
      value:
        cpu: "0"
        memory: "0"
EOF
fi
if [[ -e /tmp/assets/pythonvenv ]]; then
  echo enabling python virtual environments... >> /tmp/killercoda_setup.log
  [[ -e /tmp/apt-is-updated ]] || { apt-get update -y; touch /tmp/apt-is-updated; }
  apt-get install -y python3.12-venv
fi
if [[ -e /tmp/assets/htcondor ]]; then
  echo installing HPC batch system for ubuntu user... >> /tmp/killercoda_setup.log
  [[ -e /tmp/apt-is-updated ]] || { apt-get update -y; touch /tmp/apt-is-updated; }
  apt-get install -y minicondor </dev/null
  #Allow ubuntu user to submit jobs
  usermod -a -G docker ubuntu
  #Mount the local /etc/hosts in docker for the DNS resolution
  echo '#!/usr/bin/python
import sys, os
n=sys.argv
n[0]="/usr/bin/docker"
if "run" in n: n.insert(n.index("run")+1,"-v=/etc/hosts:/etc/hosts:ro")
os.execv(n[0],n)' > /usr/local/bin/docker
  chmod +x /usr/local/bin/docker
fi
#Stop the foreground script (we may finish our script before tail starts in the foreground, so we need to wait for it to start if it does not exist)
while ! killall tail; do sleep 1; done
