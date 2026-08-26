As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/) scripts to help us in configuring and deploying our application.

First, we clone the **release-2.1** branch of the EOEPCA Deployment Guide, to which this tutorial refers:

```
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
```{{exec}}

The Notification and Automation deployment scripts are available in the `notification-automation` directory:
```
cd deployment-guide/scripts/notification-automation
```{{exec}}


Now check the Notification and Automation prerequisites are met:
```
bash check-prerequisites.sh
```{{exec}}

This is the first Deployment Guide script run in this tutorial, so it will also ask a few questions to establish the shared EOEPCA configuration (domain, storage class, TLS) used by every building block. The domain and ingress class questions are skipped because they've already been set for you by the tutorial environment.

> Some configuration has already been established by the startup scripts of the tutorial environment. In these cases we can answer `n`{{}} to accept the current value.

Keep `eoepca.local`{{}} as the local domain shared by the EOEPCA services:
```
n
```{{exec}}

Use `local-path`{{}} to provide persistent Kubernetes volumes inside this tutorial environment:
```
local-path
```{{exec}}

We don't use cert-manager to issue certificates for individual services in this tutorial. Localcoda's proxy provides the external HTTPS instead:
```
no
```{{exec}}

The pre-requisites should now be met. You can ignore the `DNS-01` issuer warning, it is not relevant to this tutorial.
