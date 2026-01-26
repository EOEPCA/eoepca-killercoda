
As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, we download the EOEPCA Deployment Guide:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc3 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
cd deployment-guide/scripts/data-access
```{{exec}}

Now we need to check our prerequisites. In general EOEPCA Building Blocks require a Kubernetes cluster with an ingress controller to expose the interfaces and DNS entries to map the endpoints. In this tutorial, nginx is already installed and the `*.eoepca.local` domain is mapped to the nginx address.

```
bash check-prerequisites.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary pre-requirements are installed.

For our ingress controller, we will use nginx.
```
nginx
```{{exec}}


We enter the top-level domain for our EOEPCA services:
```
eoepca.local
```{{exec}}

Storage class:
```
local-path
```{{exec}}


We do not need automatically generated certificates for our tutorial:
```
no
```{{exec}}



All the prerequisites should now be met.