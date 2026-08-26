
## Prerequisites and Initial Setup

First, clone the **release-2.1** branch of the deployment-guide repository containing the necessary scripts:

<!-- TODO(release-2.1): once the eoepca-2.1 tag is published, revert this step to the tarball
     download: curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.1 | tar zx
     --transform 's|^EOEPCA[^/]*|deployment-guide|' -->
```bash
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
cd deployment-guide/scripts/app-hub
```{{exec}}

Now check that the Application Hub prerequisites are met. The Deployment Guide scripts provide a dedicated script for this:

```bash
bash check-prerequisites.sh
```{{exec}}

Keep `eoepca.local`{{}} as the local domain shared by the EOEPCA services:
```
n
```{{exec}}

Use `local-path`{{}} to provide persistent Kubernetes volumes inside this tutorial environment:
```
local-path
```{{exec}}

Disable cert-manager because Localcoda provides the tutorial's external HTTPS proxy:
```
no
```{{exec}}

All prerequisites should now be met. The IAM (Keycloak) service is being set up in the background - this may take a few minutes to complete.

You can check the status of the IAM deployment with:

```bash
kubectl get pods -n iam
```{{exec}}

Wait until all pods show `Running` status before proceeding.