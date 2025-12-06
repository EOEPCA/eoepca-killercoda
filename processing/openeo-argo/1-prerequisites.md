
## Prerequisites and Initial Setup

Clone the deployment-guide repository containing the necessary scripts and configurations.

```bash
git clone https://github.com/EOEPCA/deployment-guide -b release-2-jh
cd deployment-guide/scripts/processing/openeo-argo
```{{exec}}

Validate prerequisites:

```bash
bash check-prerequisites.sh <<EOF
http
nginx
eoepca.local
local-path
no
EOF
```{{exec}}

This checks that the Kubernetes cluster, Helm, and ingress controller are properly configured.