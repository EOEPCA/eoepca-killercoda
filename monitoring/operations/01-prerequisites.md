As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/) scripts to help us in configuring and deploying our application.

First, we clone the **release-2.1** branch of the EOEPCA Deployment Guide, to which this tutorial refers:

```
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
```{{exec}}

The Operations deployment scripts are available in the `operations` directory:
```
cd deployment-guide/scripts/operations
```{{exec}}

Operations depends only on a Kubernetes cluster, an ingress controller and an S3-compatible object store to hold Loki's log chunks — it does not require the IAM Building Block. The Deployment Guide scripts provide a dedicated script to check these prerequisites are met:
```
bash check-prerequisites.sh
```{{exec}}

This is the first Deployment Guide script run in this tutorial, so it will also ask a few questions to establish the shared EOEPCA configuration (domain, storage class, TLS) used by every building block. The ingress class question is skipped because APISIX has already been selected for you by the tutorial environment.

> Some configuration has already been established by the startup scripts of the tutorial environment. In these cases we can answer `n`{{}} to accept the current value.

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

The pre-requisites should now be met. You can see the running components with

```
kubectl get pods -A
```{{exec}}

APISIX has already been deployed for you, and a local MinIO instance is running to provide S3-compatible storage — Operations will use it as the backing store for Loki's log chunks.
