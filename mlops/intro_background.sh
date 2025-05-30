#!/bin/bash
# Script to configure prerequisites for MLOps Building Block
echo setting-up your MLOps environment... wait until this completes before starting the tutorial >> /tmp/killercoda_setup.log

if [[ -e /tmp/assets/localdns ]]; then
  echo "setting local dns entries..." >> /tmp/killercoda_setup.log
  WEBSITES="gitlab.eoepca.local sharinghub.eoepca.local mlflow.eoepca.local"
  echo "172.30.1.2 $WEBSITES" >> /etc/hosts
  kubectl get -n kube-system configmap/coredns -o yaml > kc.yml
  sed -i "s|ready|ready\n        hosts {\n          172.30.1.2 $WEBSITES\n          fallthrough\n        }|" kc.yml
  kubectl apply -f kc.yml && rm kc.yml && kubectl rollout restart -n kube-system deployment/coredns
fi

if [[ -e /tmp/assets/gomplate.7z ]]; then
  echo "installing gomplate..." >> /tmp/killercoda_setup.log
  mkdir -p /usr/local/bin/ && 7z x /tmp/assets/gomplate.7z -o/usr/local/bin/ && chmod +x /usr/local/bin/gomplate
fi

echo "setting up Helm repos..." >> /tmp/killercoda_setup.log
helm repo add gitlab https://charts.gitlab.io/ >> /tmp/killercoda_setup.log 2>&1
helm repo add sharinghub "git+https://github.com/csgroup-oss/sharinghub@deploy/helm?ref=0.4.0" >> /tmp/killercoda_setup.log 2>&1
helm repo add mlflow-sharinghub "git+https://github.com/csgroup-oss/mlflow-sharinghub@deploy/helm?ref=0.2.0" >> /tmp/killercoda_setup.log 2>&1
helm repo update >> /tmp/killercoda_setup.log 2>&1

echo "Ensuring cert-manager readiness..." >> /tmp/killercoda_setup.log
kubectl rollout status deployment -n cert-manager cert-manager --timeout=180s
kubectl rollout status deployment -n cert-manager cert-manager-webhook --timeout=180s
kubectl rollout status deployment -n cert-manager cert-manager-cainjector --timeout=180s

while ! killall tail; do sleep 1; done