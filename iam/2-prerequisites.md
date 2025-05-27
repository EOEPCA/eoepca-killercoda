## Prerequisite and Initial Configuration


Before deploying the IAM components, let's verify that our environment meets all prerequisites. This scenario provides a Kubernetes cluster (v1.28+) with **kubectl** access and **Helm 3** pre-installed. We also need an ingress controller (APISIX) and cert-manager for TLS, which we will set up.

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

1. apisix
2. http
3. eoepca.local
4. standard
5. no