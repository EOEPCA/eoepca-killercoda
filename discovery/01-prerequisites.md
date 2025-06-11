As ususal in this tutorial, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us configuring and deploying our application. 

First, we clone it in our environment:
```
git clone https://github.com/EOEPCA/deployment-guide
```{{exec}}

and checkout the current release

```
cd deployment-guide
git checkout eoepca-2.0-rc1
```{{exec}}

The Rescource Catalogue deployment scripts are available in the `resource-discovery` directory:
```
cd scripts/resource-discovery
```{{exec}}

Next we'll check whether the prerequisites for installing the Resource Discovery building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary prerequirements are installed. 

EOEPCA conponents can work with different Ingress services installed in your Kubernetes cluster. The default configuration uses [apisix](https://apisix.apache.org/) to provide advanced authentication and autorization. For this demo environment, we will use the simpler nginx ingress without authorization

```
nginx
```{{exec}}

We choose th `http` scheme since we are not using certificates and encryption for our tutorial:
```
http
```{{exec}}

We enter the top-level domain for our EOEPCA services:
```
eoepca.local
```{{exec}}

We do not need a specific Storage Class for this component, so for this example we will use the basic storage class provided by Killercoda:

```
local-path
```{{exec}}

We also do not need automatically generated certificates or indeed any certificates at all for our tutorial:
```
no
```{{exec}}

Now, all the pre-requisites should be met
