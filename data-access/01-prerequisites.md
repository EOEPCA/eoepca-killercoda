
As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, we download the EOEPCA Deployment Guide:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
cd deployment-guide/scripts/data-access
```{{exec}}

Now we need to check our prerequisites. In general EOEPCA Building Blocks require a Kubernetes cluster with an ingress controller to expose the interfaces and DNS entries to map the endpoints. In this tutorial, nginx is already installed and the `*.eoepca.local` domain is mapped to the nginx address.

```
bash check-prerequisites.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary pre-requirements are installed.

> Some configuration has already been established by the startup scripts of the tutorial environment. In these cases we can answer `n`{{}} to accept the current value.

Select nginx as the ingress controller that routes external requests to the Data Access services.
```
nginx
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



All the prerequisites should now be met.
