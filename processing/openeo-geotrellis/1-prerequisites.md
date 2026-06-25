## Prerequisites and Initial Setup

First, download the `eoepca-2.0` release branch of the Deployment Guide. The archive is extracted into `/root/deployment-guide`, and the second command moves us to the OpenEO deployment scripts used throughout this tutorial.

```bash
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
cd deployment-guide/scripts/processing/openeo
```{{exec}}

Next we need to check that the prerequisites for installing the OpenEO building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

This starts an interactive setup. Run each answer below only when its corresponding prompt appears.

EOEPCA components can work with different Ingress services installed in your Kubernetes cluster. The default configuration uses [APISIX](https://apisix.apache.org/) to provide advanced authentication and authorization. For this demo environment, we will use the simpler NGINX Ingress without authorization:

```
nginx
```{{exec}}

Localcoda has already set the top-level domain to `eoepca.local`. When asked whether to update `INGRESS_HOST`, keep that value:

```
no
```{{exec}}

We do not need a specific StorageClass for this component, so for this example we will use the basic storage class provided in this sandbox. In an operational environment, use a reliable, backed-up storage class for persistent data:

```
local-path
```{{exec}}

We do not need automatically generated TLS certificates for this tutorial:

```
no
```{{exec}}

The script should finish with `All prerequisites are met`. It also saves the answers in `~/.eoepca/state`; later configuration scripts reuse this shared state.

If you want to learn more about these settings, follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Prerequisites</a> tutorial.
