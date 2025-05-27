#!/bin/bash
#Script to set pre-requisites for EOEPCA components
echo setting-up your IAM environment... wait till this setup terminates before starting the tutorial >> /tmp/killercoda_setup.log
if [[ -e /tmp/assets/localdns ]]; then
  #DNS-es for dependencies
  echo "setting local dns..." >> /tmp/killercoda_setup.log
  WEBSITES="auth.eoepca.local opa.eoepca.local"
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

# install apisix
echo "installing apisix..." >> /tmp/killercoda_setup.log
helm repo add apisix https://charts.apiseven.com
helm repo update apisix

helm upgrade -i apisix apisix/apisix \
  --version 2.9.0 \
  --namespace ingress-apisix --create-namespace \
  --set service.type=NodePort \
  --set service.http.nodePort=31080 \
  --set service.tls.nodePort=31443 \
  --set apisix.enableIPv6=false \
  --set apisix.enableServerTokens=false \
  --set apisix.ssl.enabled=true \
  --set apisix.pluginAttrs.redirect.https_port=443 \
  --set ingress-controller.enabled=true

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml

echo "waiting for cert-manager to be ready..." >> /tmp/killercoda_setup.log

kubectl -n cert-manager rollout status deployment cert-manager-webhook --timeout=120s

kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
EOF

# apply the file in assets/apisix-tls.yaml
if [[ -e /tmp/assets/apisix-tls.yaml ]]; then
  echo "applying apisix-tls.yaml..." >> /tmp/killercoda_setup.log
  kubectl apply -f /tmp/assets/apisix-tls.yaml
fi

#Stop the foreground script (we may finish our script before tail starts in the foreground, so we need to wait for it to start if it does not exist)
while ! killall tail; do sleep 1; done