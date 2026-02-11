#!/bin/bash
#Script to set pre-requisites for EOEPCA components
echo setting-up your environment... wait till this setup terminates before starting the tutorial >> /tmp/killercoda_setup.log
if [[ -e /tmp/assets/killeditor ]]; then
  echo "disabling editor to recover RAM (editor tab on the left will not work anymore)..." >> /tmp/killercoda_setup.log
  killall /opt/theia/node
  #Stop services 
  echo "stopping optional services to recover RAM..." >> /tmp/killercoda_setup.log
  #Unattended upgrades
  killall /usr/bin/python3
  #Disks management
  service udisks2 stop
  #Bluethooth management
  service ModemManager stop
  #Disk RAID services
  service multipathd stop
  #Local ssh
  service ssh stop
fi
if [[ -e /tmp/assets/k3s ]]; then
  echo "installing kubernetes via k3s..." >> /tmp/killercoda_setup.log
  #Installing k3s with most features disabled, including zero thresholds for nodes and memory pressure
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik --disable=servicelb --disable=metrics-server --kubelet-arg=eviction-hard= --kubelet-arg=eviction-soft= --kubelet-arg=eviction-soft-grace-period= --kubelet-arg=eviction-max-pod-grace-period=0" INSTALL_K3S_SKIP_ENABLE=true sh -
  #Starting the service
  systemctl start k3s
  echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  echo "waiting for kubernetes to start..." >> /tmp/killercoda_setup.log
  while ! kubectl wait --for=condition=Ready --all=true -A pod --timeout=1m &>/dev/null; do sleep 1; done
fi
if [[ -e /tmp/assets/localdns ]]; then
  #DNS-es for dependencies
  echo "setting local dns..." >> /tmp/killercoda_setup.log
  WEBSITES="`tr -d '\n' < /tmp/assets/localdns`"

  if ! echo "172.30.1.2 $WEBSITES" >> /etc/hosts 2>/dev/null; then
    cp /etc/hosts /tmp/hosts.tmp
    echo "172.30.1.2 $WEBSITES" >> /tmp/hosts.tmp
    mount --bind /tmp/hosts.tmp /etc/hosts
  fi
  
  kubectl get -n kube-system configmap/coredns -o yaml > kc.yml
  sed -i -e ':a;N;$!ba;s|hosts[^{]*{[^}]*}||g' -e "s|ready|ready\n        hosts {\n          172.30.1.2 $WEBSITES\n          fallthrough\n        }|" kc.yml
  kubectl apply -f kc.yml && rm kc.yml && kubectl rollout restart -n kube-system deployment/coredns && kubectl rollout status -n kube-system deployment/coredns --timeout=60s
  mkdir -p ~/.eoepca && cat <<EOF >>~/.eoepca/state
export HTTP_SCHEME="http"
export INGRESS_HOST="eoepca.local"
EOF
fi
if [[ -e /tmp/assets/gomplate.7z ]]; then
  echo "installing gomplate..." >> /tmp/killercoda_setup.log
  #Gomplate is a dependency of the deployment tool
  #Installing it from local instead then remote for speed
  #curl -s -S -L -o /usr/local/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v4.3.0/gomplate_linux-amd64 && chmod +x /usr/local/bin/gomplate
  which 7z &>/dev/null || { [[ -e /tmp/apt-is-updated ]] || { apt-get update -y; touch /tmp/apt-is-updated; }; apt-get install -y 7zip; }
  which helm &>/dev/null || curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  mkdir -p /usr/local/bin/ && 7z x /tmp/assets/gomplate.7z -o/usr/local/bin/ && chmod +x /usr/local/bin/gomplate
fi
if [[ -e /tmp/assets/nginxingress ]]; then
  #Installing Ingress (basic)
  echo installing nginx ingress... >> /tmp/killercoda_setup.log
  which helm &>/dev/null || curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --create-namespace \
    --set controller.hostNetwork=true \
    --set controller.allowSnippetAnnotations=true \
    --set controller.config.annotations-risk-level=Critical
fi
if [[ -e /tmp/assets/apisix ]]; then
  # Install apisix
  echo "installing apisix ingress..." >> /tmp/killercoda_setup.log
  mkdir -p ~/.eoepca && echo 'export INGRESS_CLASS="apisix"' >> ~/.eoepca/state
  helm repo add apisix https://charts.apiseven.com
  helm repo update apisix
  helm upgrade -i apisix apisix/apisix \
    --version 2.10.0 \
    --namespace ingress-apisix --create-namespace \
    --set securityContext.runAsUser=0 \
    --set hostNetwork=true \
    --set service.http.containerPort=80 \
    --set apisix.ssl.containerPort=443 \
    --set etcd.image.repository=bitnamilegacy/etcd \
    --set etcd.replicaCount=1 \
    --set etcd.persistence.storageClass="local-path" \
    --set apisix.enableIPv6=false \
    --set apisix.enableServerTokens=false \
    --set apisix.ssl.enabled=true \
    --set ingress-controller.enabled=true
fi
if [[ -e /tmp/assets/killercodaproxy ]]; then
  #Use an NGinx proxy to force the Host and replace the links to allow most applciations
  #to work with killercoda proxy
  echo configuring proxy for killercoda external access... >> /tmp/killercoda_setup.log
  [[ -e /tmp/apt-is-updated ]] || { apt-get update -y; touch /tmp/apt-is-updated; }
  #Install nginx with substitution mode
  apt-get install -y nginx libnginx-mod-http-subs-filter
  #Create logs directories
  mkdir -p /var/log/nginx/
  #source eoepca state - e.g. for HTTP_SCHEME
  source ~/.eoepca/state
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
  map \$http_upgrade \$connection_upgrade {
    default upgrade;
    ''      close;
  }
  # Large buffer sizes for handling large headers (e.g., auth tokens, OIDC flows etc.)
  proxy_buffer_size          32k;
  proxy_buffers              8 32k;
  proxy_busy_buffers_size    64k;
  large_client_header_buffers 4 32k;
EOF
  #All the proxy redirects must be placed into all the proxied sites, otherwise cross-site
  #redirections like the ones done by OPA will not work...
  echo -n "" > /tmp/assets/killercodaproxy_redirects
  while read port dest types; do
    echo "      proxy_redirect http://$dest `sed -e "s/PORT/$port/g" /etc/killercoda/host`;" >> /tmp/assets/killercodaproxy_redirects
  done < /tmp/assets/killercodaproxy
  # helper function to add an nginx server block
  add_server_block() {
    local port="$1" dest="$2" types="$3"
    local host="${4:-$dest}"
    cat <<EOF>>/etc/nginx/nginx.conf
  server {
    listen       $port;
    location / {
      proxy_pass  http://$dest;
      proxy_set_header Host $host;
      proxy_set_header Accept-Encoding "";
      proxy_set_header X-Forwarded-Host \$http_x_forwarded_host;
      proxy_set_header X-Forwarded-Proto \$http_x_forwarded_proto;
      proxy_set_header X-Forwarded-For \$http_x_forwarded_for;
      proxy_set_header X-Forwarded-Port \$http_x_forwarded_port;
      # websockets
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection \$connection_upgrade;
      # streaming - e.g. for S3 API
      client_max_body_size 0;
      proxy_request_buffering off;
EOF
    cat /tmp/assets/killercodaproxy_redirects >> /etc/nginx/nginx.conf
    [[ "$types" != "NONE" && "$types" != "'NONE'" ]] && cat <<EOF>>/etc/nginx/nginx.conf
      subs_filter http://$dest  `sed -e "s/PORT/$port/g" /etc/killercoda/host`;
      subs_filter $dest  `sed -e "s|^https\?://PORT|$port|" /etc/killercoda/host`;
      subs_filter_types ${types//\'/};
EOF
    cat <<EOF>>/etc/nginx/nginx.conf
    }
  }
EOF
  }
  # Add server blocks
  while read port dest types; do
    add_server_block "$port" "$dest" "$types"
  done < /tmp/assets/killercodaproxy
  # Add minio servers if enabled
  # These need to set the Host header as the 'external' URL - minio is fussy
  if [[ -e /tmp/assets/minio.7z ]]; then
    add_server_block 900 "minio.eoepca.local:9000" "NONE" "$(sed "s#http://PORT#900#" /etc/killercoda/host)"  # S3 API
    add_server_block 901 "minio-console.eoepca.local:9001" "NONE" "$(sed "s#http://PORT#901#" /etc/killercoda/host)"  # Web Console
  fi
  # close the http block
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
  minio_console_url="$(sed "s#PORT#9001#" /etc/killercoda/host)"
  mkdir -p ~/minio && \
    MINIO_ROOT_USER=eoepca MINIO_ROOT_PASSWORD=eoepcatest MINIO_BROWSER_REDIRECT_URL="${minio_console_url}" MINIO_PROXY=on MINIO_API_CORS_ALLOW_ORIGIN="${minio_console_url}" \
    nohup minio server --quiet --console-address ":9001" ~/minio &>/dev/null &
  sleep 1
  while ! mc config host add minio-local http://minio.eoepca.local:9000/ eoepca eoepcatest; do sleep 1; done
  mkdir -p ~/.eoepca && echo 'export S3_ENDPOINT="http://minio.eoepca.local:9000/"
export S3_HOST="minio.eoepca.local:9000"
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
  mkdir -p ~/.eoepca && echo 'export SHARED_STORAGECLASS="standard"'>>~/.eoepca/state
fi
if [[ -e /tmp/assets/ignoreresrequests ]]; then
  ### Avoid applyiing resource limits, otherwise Clarissian will not work as limits are hardcoded in there...
  ### THIS IS JUST FOR DEMO! DO NOT DO THIS PART IN PRODUCTION!
  echo configuring kyverno to ignore resource limits...  >> /tmp/killercoda_setup.log
  helm repo add kyverno https://kyverno.github.io/kyverno/
  helm repo update kyverno
  helm upgrade -i kyverno kyverno/kyverno \
    --version 3.6.2 \
    --namespace kyverno \
    --create-namespace
  # Create the cluster policy to remove resource limits/requests
  # Note that, rather than zero, we actually set minimal cpu/memory requests to avoid potential issues
  # with certain workloads that may not handle zero resource requests gracefully.
  cat - <<'EOF' | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: remove-resource-requests
spec:
  rules:
    - name: remove-resource-requests
      match:
        any:
          - resources:
              kinds:
                - Pod
      mutate:
        foreach:
          # --- Containers ---
          - list: "to_array(request.object.spec.containers)"
            patchStrategicMerge:
              spec:
                containers:
                  - name: "{{ element.name }}"
                    resources:
                      requests:
                        cpu: "1m"
                        memory: "1M"

          # --- Init containers ---
          - list: "to_array(request.object.spec.initContainers)"
            preconditions:
              all:
                - key: "{{ length(to_array(request.object.spec.initContainers)) }}"
                  operator: GreaterThan
                  value: 0
            patchStrategicMerge:
              spec:
                initContainers:
                  - name: "{{ element.name }}"
                    resources:
                      requests:
                        cpu: "1m"
                        memory: "1M"
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
  echo '#!/usr/bin/python3
import sys, os
n=sys.argv
n[0]="/usr/bin/docker"
if "run" in n: n.insert(n.index("run")+1,"-v=/etc/hosts:/etc/hosts:ro")
os.execv(n[0],n)' > /usr/local/bin/docker
  chmod +x /usr/local/bin/docker
fi
if [[ -e /tmp/assets/postgrespostgis ]]; then
  echo "installing PostgreSQL+PostGIS..."  >> /tmp/killercoda_setup.log
  [[ -e /tmp/apt-is-updated ]] || { apt-get update -y; touch /tmp/apt-is-updated; }
  #Install latest postgresql release
  apt-get install -y postgresql-common </dev/null
  /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
  apt-get install -y postgresql postgresql-postgis < /dev/null
  #Locate installed version
  PG_VERSION=`ls /etc/postgresql/`
  su - postgres -c "echo \"listen_addresses = '*'\" >> /etc/postgresql/$PG_VERSION/main/postgresql.conf"
  su - postgres -c "echo \"host all all 0.0.0.0/0 scram-sha-256\" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf"
  service postgresql restart
  while read dbname dbuser dbpass; do
    su - postgres -c "psql -c \"CREATE USER $dbuser WITH PASSWORD '$dbpass'\"; createdb -O $dbuser $dbname"
    su - postgres -c "psql -c \"CREATE EXTENSION postgis;\" $dbname"
  done < /tmp/assets/postgrespostgis
fi
if [[ -e /tmp/assets/k9s ]]; then
  echo installing k9s kubernetes CLI... >> /tmp/killercoda_setup.log
  curl -JOLs https://github.com/derailed/k9s/releases/download/v0.50.16/k9s_linux_amd64.deb
  [[ -e /tmp/apt-is-updated ]] || { apt-get update -y; touch /tmp/apt-is-updated; }
  sudo apt install -y ./k9s_linux_amd64.deb
  rm k9s_linux_amd64.deb
fi
if [[ -e /tmp/assets/crossplane ]]; then
  # Deploy Crossplane
  echo installing crossplane...  >> /tmp/killercoda_setup.log
  # Deploy Crossplane via helm chart
  helm upgrade --install crossplane crossplane \
    --repo https://charts.crossplane.io/stable \
    --version 2.0.2 \
    --namespace crossplane-system \
    --create-namespace \
    --set provider.defaultActivations={}
  # Secret with Minio credentials for Crossplane S3 provider
  source ~/.eoepca/state
  kubectl create secret generic minio-secret \
    --from-literal=AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY" \
    --from-literal=AWS_SECRET_ACCESS_KEY="$S3_SECRET_KEY" \
    --from-literal=AWS_ENDPOINT_URL="$S3_ENDPOINT" \
    --from-literal=AWS_REGION="$S3_REGION" \
    --namespace crossplane-system
  # Deploy providers and associated setup
  echo "waiting for crossplane to start (this may take a while)..."  >> /tmp/killercoda_setup.log
  until kubectl apply -f /tmp/assets/crossplane &>/dev/null; do
    sleep 2
  done
fi
if [[ -e /tmp/assets/iam ]]; then
  echo "installing IAM..." >> /tmp/killercoda_setup.log
  keycloak_host() {
    port="$(grep auth /tmp/assets/killercodaproxy | awk '{print $1}')"
    sed "s#http://PORT#$port#" /etc/killercoda/host
  }
  source ~/.eoepca/state
  export REALM="eoepca"
  export KEYCLOAK_HOST="$(keycloak_host)"
  mkdir -p ~/.eoepca && cat <<EOF >>~/.eoepca/state
export REALM="${REALM}"
export KEYCLOAK_HOST="${KEYCLOAK_HOST}"
export OIDC_ISSUER_URL="${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/${REALM}"
export KEYCLOAK_ADMIN_USER="admin"
export KEYCLOAK_ADMIN_PASSWORD="eoepcatest"
export KEYCLOAK_POSTGRES_PASSWORD="eoepcatest"
export OPA_CLIENT_ID="opa"
export OPA_CLIENT_SECRET="$(openssl rand -hex 16)"
export KEYCLOAK_TEST_USER="eoepcauser"
export KEYCLOAK_TEST_ADMIN="eoepcaadmin"
export KEYCLOAK_TEST_PASSWORD="eoepcapassword"
EOF
  source ~/.eoepca/state
  source /tmp/assets/iam
  kubectl create namespace iam
  # Secrets
  iam_create_secrets
  # Helm chart
  helm repo add eoepca https://eoepca.github.io/helm-charts
  helm repo update eoepca
  iam_helm_values | helm upgrade -i iam eoepca/iam-bb \
    --version 2.0.0 \
    --namespace iam \
    --values - \
    --create-namespace
  # IAM post-setup - do this in the background
  # Wait for IAM to be ready
  echo "waiting IAM to be ready (this may take a while)..." >> /tmp/killercoda_setup.log
  while ! kubectl wait --for=condition=Ready --all=true -n iam pod --timeout=1m &>/dev/null; do sleep 1; done
  until curl -sf "http://auth.eoepca.local/realms/master/.well-known/openid-configuration" >/dev/null; do
    echo "Waiting for Keycloak OIDC discovery..."
    sleep 2
  done
  # Wait for Crossplane Keycloak CRDs to be available
  echo "waiting for Crossplane Keycloak CRDs (this may also take a while)..." >> /tmp/killercoda_setup.log
  until kubectl get crd providerconfigs.keycloak.m.crossplane.io &>/dev/null; do
    sleep 5
  done
  # Create eoepca realm
  iam_create_realm
  # Create IAM management client
  iam_create_management_client
  iam_configure_management_client
  # Crossplane provider setup
  iam_setup_crossplane_provider
  # Test users
  iam_create_test_users
  # OPA client
  iam_create_opa_client
fi
if [[ -e /tmp/assets/waitforpods ]]; then
  echo "waiting for all service pods to be ready (this may take some time)..." >> /tmp/killercoda_setup.log
  kubectl wait --for=condition=Ready pod --all --all-namespaces --timeout=-1s >> /tmp/killercoda_setup.log
fi
#Stop the foreground script (we may finish our script before tail starts in the foreground, so we need to wait for it to start if it does not exist)
while ! killall tail; do sleep 1; done
