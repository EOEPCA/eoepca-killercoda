#!/bin/bash
reset; tail -f /tmp/killercoda_setup.log; source ~/.bashrc;

echo
echo
echo "basesetup completed! installing resource discovery BB..."

# Script to install the pre-requisite Resource Discovery building block
echo setting-up resource discovery BB... wait till this setup terminates before starting the tutorial >> /tmp/killercoda_setup.log
mkdir /tmp/discovery-setup
cd /tmp/discovery-setup
git clone https://github.com/EOEPCA/deployment-guide
cd deployment-guide/scripts/resource-discovery
echo "http
nginx
eoepca.local
local-path
no" | bash check-prerequisites.sh

echo "no
no" | bash configure-resource-discovery.sh

helm repo add eoepca https://eoepca.github.io/helm-charts
helm repo update eoepca

echo
echo
echo "Waiting for Kubernetes to start..."
while ! kubectl get nodes; do sleep 1; done

echo
echo
echo "Kubernetes started, installing resource discovery Helm chart"
helm upgrade -i resource-discovery eoepca/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.0.0 \
  --namespace resource-discovery \
  --create-namespace

kubectl apply -f generated-ingress.yaml

echo
echo
echo "Waiting for resource discovery BB to start (may take several minutes)"
while [[ `curl -s -o /dev/null -w "%{http_code}" "http://resource-catalogue.eoepca.local/stac"` != 200 ]]; do sleep 1; done

echo "setup completed! you can start the tutorial now!"
