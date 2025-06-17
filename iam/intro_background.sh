#!/bin/bash
#Script to set pre-requisites for EOEPCA components
echo setting-up your IAM environment... wait till this setup terminates before starting the tutorial >> /tmp/killercoda_setup.log
if [[ -e /tmp/assets/localdns ]]; then
  #DNS-es for dependencies
  echo "setting local dns..." >> /tmp/killercoda_setup.log
  WEBSITES="auth.eoepca.local opa.eoepca.local identity-api.eoepca.local nginx.eoepca.local nginx-open.eoepca.local"
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

if [[ -e /tmp/assets/ignoreresrequests ]]; then
  ### Avoid applyiing resource limits
  ### THIS IS JUST FOR DEMO! DO NOT DO THIS PART IN PRODUCTION!
  echo -n "setting resource limits..."  >> /tmp/killercoda_setup.log
  kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.18.2/deploy/gatekeeper.yaml
  kubectl scale --replicas=1 deploy/gatekeeper-controller-manager -n gatekeeper-system
  echo -n "-> waiting for gatekeeper readiness..."  >> /tmp/killercoda_setup.log
  # wait for pods
  kubectl rollout status deploy/gatekeeper-controller-manager -n gatekeeper-system
  kubectl rollout status deploy/gatekeeper-audit -n gatekeeper-system
  # wait for service readiness
  POD_NAME=$(kubectl -n gatekeeper-system get pods -l gatekeeper.sh/operation=webhook -o jsonpath='{.items[0].metadata.name}')
  kubectl -n gatekeeper-system port-forward pod/$POD_NAME 9090:9090 &
  PF_PID=$!
  until curl -f localhost:9090/readyz >/dev/null 2>&1; do
    echo "Waiting for Gatekeeper webhook to be ready..."
    sleep 1
  done
  kill $PF_PID
  echo "-> READY"  >> /tmp/killercoda_setup.log
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

# install apisix
if [[ -e /tmp/assets/apisix ]]; then
  echo "installing apisix..." >> /tmp/killercoda_setup.log
  helm repo add apisix https://charts.apiseven.com >> /tmp/killercoda_setup.log 2>&1
  helm repo update apisix >> /tmp/killercoda_setup.log 2>&1

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
    --set ingress-controller.enabled=true \
    >> /tmp/killercoda_setup.log 2>&1

  # apisix - wait for all pods
  echo -n "waiting for apisix readiness..." >> /tmp/killercoda_setup.log
  kubectl -n ingress-apisix rollout status \
    deployment.apps/apisix \
    deployment.apps/apisix-ingress-controller \
    statefulset.apps/apisix-etcd \
    >> /tmp/killercoda_setup.log 2>&1
  echo "-> READY"  >> /tmp/killercoda_setup.log
  echo "APISIX successfully deployed" >> /tmp/killercoda_setup.log
fi

# k9s - useful for debugging
if [[ -e /tmp/assets/k9s ]]; then
  echo -n "installing k9s......" >> /tmp/killercoda_setup.log
  curl -JOLs https://github.com/derailed/k9s/releases/download/v0.50.6/k9s_linux_amd64.deb
  apt install -y ./k9s_linux_amd64.deb
  rm -f ./k9s_linux_amd64.deb
  echo "-> DONE" >> /tmp/killercoda_setup.log
fi

# Stop the foreground script (we may finish our script before tail starts in the foreground, so we need to wait for it to start if it does not exist)
while ! killall tail; do sleep 1; done
