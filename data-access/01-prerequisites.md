
As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, we download the EOEPCA Deployment Guide:

```
git clone https://github.com/EOEPCA/deployment-guide --branch release-2-jh
cd deployment-guide/scripts/data-access
```{{exec}}

Now we need to check our prerequisites. In general EOEPCA Building Blocks require a Kubernetes cluster with an ingress controller to expose the interfaces and DNS entries to map the endpoints. In this tutorial, nginx is already installed and the `*.eoepca.local` domain is mapped to the nginx address.

```
bash check-prerequisites.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary pre-requirements are installed.

EOEPCA components can work with or without certificates. We choose the `http` scheme since we are not using certificates and encryption for our tutorial:
```
http
```{{exec}}

EOEPCA components can work with different Ingress services installed in your Kubernetes cluster. For this demo environment, we will use the nginx ingress:
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