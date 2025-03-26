reset
echo setting-up your environment...
#DNS-es for dependencies
echo "172.30.1.2 minio.eoepca.local zoo.eoepca.local" >> /etc/hosts
kubectl get -n kube-system configmap/coredns -o yaml > kc.yml
sed -i "s|ready|ready\n        hosts {\n          172.30.1.2 minio.eoepca.local zoo.eoepca.local\n          fallthrough\n        }|" kc.yml
kubectl apply -f kc.yml &>/tmp/kube_coredns.log && rm kc.yml && kubectl rollout restart -n kube-system deployment/coredns &>>/tmp/kube_coredns.log
#Common binaries (we have this locally installed for speed and to keep the versions)
mkdir -p /usr/local/bin/ && 7z x /tmp/commons_bin.7z -o /usr/local/bin/ && chmod +x /usr/local/bin/gomplate /usr/local/bin/mc /usr/local/bin/minio
#gotemplate scripts
#curl -s -S -L -o /usr/local/bin/gomplate https://github.com/hairyhenderson/gomplate/releases/download/v4.3.0/gomplate_linux-amd64 &>/tmp/install_gotemplate.log && chmod +x /usr/local/bin/gomplate
#Installing Ingress (basic)
echo installing basic ingress...
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
	--set controller.hostNetwork=true &> /tmp/install_ingress.log
#Installing Minio (basic)
echo enabling object storage...
### Prerequisite: minio
#We have this locally installed for speed
#wget -q https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio && chmod +x /usr/local/bin/minio &> /tmp/install_minio.log
#wget -q https://dl.min.io/client/mc/release/linux-amd64/mc -O  /usr/local/bin/mc && chmod +x /usr/local/bin/mc &>> /tmp/install_minio.log
mkdir -p ~/minio && MINIO_ROOT_USER=eoepca MINIO_ROOT_PASSWORD=eoepcatest nohup minio server --quiet ~/minio &>/dev/null &
mc config host add minio-local http://minio.eoepca.local:9000/ eoepca eoepcatest &>>/tmp/install_minio.log
mc mb minio-local/eoepca &>>/tmp/install_minio.log
mkdir -p ~/.eoepca && echo 'export S3_ENDPOINT="http://minio.eoepca.local:9000/"
export S3_ACCESS_KEY="eoepca"
export S3_SECRET_KEY="eoepcatest"
export S3_REGION="us-east-1"' >> ~/.eoepca/state
### Prerequisites: readwritemany StorageClass
echo enabling ReadWriteMany StorageClass..
kubectl apply -f https://raw.githubusercontent.com/EOEPCA/deployment-guide/refs/heads/main/docs/prerequisites/hostpath-provisioner.yaml &>>/tmp/install_rwm_storageclass.log
echo 'export STORAGE_CLASS="standard"'>>~/.eoepca/state
### Avoid applyiing resource limits, otherwise Clarissian will not work as limits are hardcoded in there...
### THIS IS JUST FOR DEMO! DO NOT DO THIS PART IN PRODUCTION!
echo setting resource limits...
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.18.2/deploy/gatekeeper.yaml &>/tmp/install_skiplimits.log
cat <<EOF | kubectl apply -f - 2>&1 >>/tmp/install_skiplimits.log
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
echo setup complete! you can start the tutorial...