
## Prerequisites and Initial Setup

First, download the latest deployment-guide repository containing the necessary scripts:

```bash
curl -L https://github.com/EOEPCA/deployment-guide/tarball/main | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
cd deployment-guide/scripts/app-hub
```{{exec}}

Now check that the Application Hub prerequisites are met. The Deployment Guide scripts provide a dedicated script for this:

```bash
bash check-prerequisites.sh
```{{exec}}

All prerequisites should now be met. The IAM (Keycloak) service is being set up in the background - this may take a few minutes to complete.

You can check the status of the IAM deployment with:

```bash
kubectl get pods -n iam
```{{exec}}

Wait until all pods show `Running` status before proceeding.