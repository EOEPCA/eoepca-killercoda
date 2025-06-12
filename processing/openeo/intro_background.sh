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
    --set controller.service.type=NodePort \
    --set controller.service.nodePorts.http=30080 \
    --set controller.service.nodePorts.https=30443 \
    --set controller.allowSnippetAnnotations=true \
    --set controller.config.annotations-risk-level=Critical
fi


helm plugin install https://github.com/aslafy-z/helm-git --version 1.3.0

echo -e "\n# Custom Kubernetes Aliases\nalias k=kubectl\nalias o=xdg-open\nalias ns=~/set-namespace.sh\nalias vcc=\"vcluster connect vcluster-deployment-test --namespace vcluster-deployment-test\"\nalias p=\"kubectl get pods\"\nalias lo=\"kubectl logs\"\nalias i=\"kubectl get ingress\"\nalias svc=\"kubectl get svc\"\nalias pvc=\"kubectl get pvc\"\nalias d=\"kubectl describe pod\"" >> ~/.bashrc
source ~/.bashrc

cat <<'EOF' > ~/set-namespace.sh
#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <namespace>"
    exit 1
fi

NAMESPACE="$1"

echo "Setting the default namespace to: $NAMESPACE"

kubectl config set-context --current --namespace="$NAMESPACE"

if [ $? -eq 0 ]; then
    echo "Namespace successfully set."
else
    echo "Failed to set namespace."
fi
EOF

chmod +x ~/set-namespace.sh

sudo fallocate -l 1G /swapfile && chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
sudo sysctl -w vm.swappiness=10

helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update kyverno
helm upgrade -i kyverno kyverno/kyverno \
  --version 3.4.1 \
  --namespace kyverno \
  --create-namespace


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
          - list: "request.object.spec.containers"
            patchStrategicMerge:
              spec:
                containers:
                  - name: "{{ element.name }}"
                    resources:
                      requests:
                        cpu: "0"
                        memory: "0"
          - list: "request.object.spec.initContainers || []"
            preconditions:
              all:
                - key: "{{ length(request.object.spec.initContainers) }}"
                  operator: GreaterThan
                  value: 0
            patchStrategicMerge:
              spec:
                initContainers:
                  - name: "{{ element.name }}"
                    resources:
                      requests:
                        cpu: "0"
                        memory: "0"
EOF

# Clean up unused container images to free up disk space
echo "cleaning up unused container images..." >> /tmp/killercoda_setup.log
# Remove unused container images
crictl rmi --prune >> /tmp/killercoda_setup.log 2>&1

if command -v docker &> /dev/null; then
  docker image prune -af >> /tmp/killercoda_setup.log 2>&1
  docker container prune -f >> /tmp/killercoda_setup.log 2>&1
  docker volume prune -f >> /tmp/killercoda_setup.log 2>&1
fi

if command -v journalctl &> /dev/null; then
  journalctl --vacuum-time=2d >> /tmp/killercoda_setup.log 2>&1
fi

if command -v apt-get &> /dev/null; then
  apt-get autoremove -y >> /tmp/killercoda_setup.log 2>&1
  apt-get clean >> /tmp/killercoda_setup.log 2>&1
fi

if command -v dnf &> /dev/null; then
  dnf autoremove -y >> /tmp/killercoda_setup.log 2>&1
  dnf clean all >> /tmp/killercoda_setup.log 2>&1
elif command -v yum &> /dev/null; then
  yum autoremove -y >> /tmp/killercoda_setup.log 2>&1
  yum clean all >> /tmp/killercoda_setup.log 2>&1
fi

find /tmp -type f -atime +2 -delete
find /var/tmp -type f -atime +2 -delete

find /var/log -type f -name "*.log.*" -delete
find /var/log -type f -name "*.gz" -delete

while ! killall tail; do sleep 1; done