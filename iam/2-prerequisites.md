## Prerequisite and Initial Configuration


Before deploying the IAM components, ensure your environment is ready. This scenario provides a Kubernetes cluster (v1.28+) with **kubectl** access, **Helm 3**, an **APISIX** ingress controller and **cert-manager**: already set up.

**Clone Deployment Scripts:** First, clone the EOEPCA Deployment Guide repository to get the helper scripts and navigate to the IAM scripts directory:

```bash
git clone https://github.com/EOEPCA/deployment-guide.git

cd deployment-guide/scripts/iam
``` 

Run Prerequisites Check:

```bash
bash check-prerequisites.sh
```

As this will be the first time we are running any EOEPCA script, there will be initial setup steps.
1. **Ingress class**: `apisix`
2. **HTTP scheme**: `http`
3. **Ingress host**: `eoepca.local`
4. **Storage class**: `local-path`
5. **Cert-manager enabled**: `no`

Alternatively, run this:

```bash
bash check-prerequisites.sh <<EOF
apisix
http
eoepca.local
local-path
no
EOF
```