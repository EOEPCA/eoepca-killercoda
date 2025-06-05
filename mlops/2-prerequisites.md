
## Prerequisites and Initial Configuration

Ensure the following are available (already provided in this environment):

- Kubernetes cluster (v1.28+)
- Helm 3
- APISIX ingress controller
- cert-manager
- MinIO S3-compatible storage
  
Clone deployment scripts:

```bash
git clone https://github.com/EOEPCA/deployment-guide.git -b killercoda-jh-changes

cd deployment-guide/scripts/mlops
```{{exec}}

Run the prerequisites check:

```bash
bash check-prerequisites.sh <<EOF
http
nginx
eoepca.local
local-path
no
EOF
```{{exec}}