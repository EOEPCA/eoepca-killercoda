#!/bin/bash
# Script to configure prerequisites for MLOps Building Block
echo setting-up your MLOps environment... wait until this completes before starting the tutorial >> /tmp/killercoda_setup.log

if [[ -e /tmp/assets/localdns ]]; then
  echo "setting local dns entries..." >> /tmp/killercoda_setup.log
  WEBSITES="minio.eoepca.local gitlab.eoepca.local sharinghub.eoepca.local mlflow.eoepca.local"
  echo "172.30.1.2 $WEBSITES" >> /etc/hosts
  kubectl get -n kube-system configmap/coredns -o yaml > kc.yml
  sed -i "s|ready|ready\n        hosts {\n          172.30.1.2 $WEBSITES\n          fallthrough\n        }|" kc.yml
  kubectl apply -f kc.yml && rm kc.yml && kubectl rollout restart -n kube-system deployment/coredns
fi
if [[ -e /tmp/assets/gomplate.7z ]]; then
  echo "installing gomplate..." >> /tmp/killercoda_setup.log
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
  mc mb minio-local/eoepca
  mkdir -p ~/.eoepca && echo 'export S3_ENDPOINT="http://minio.eoepca.local:9000/"
export S3_ACCESS_KEY="eoepca"
export S3_SECRET_KEY="eoepcatest"
export S3_REGION="us-east-1"' >> ~/.eoepca/state
fi

helm plugin install https://github.com/aslafy-z/helm-git --version 1.3.0

while ! killall tail; do sleep 1; done