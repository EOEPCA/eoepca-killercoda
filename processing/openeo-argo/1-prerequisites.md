
## Prerequisites and Initial Setup

Clone the deployment-guide repository containing the necessary scripts and configurations.

```bash
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc3 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
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