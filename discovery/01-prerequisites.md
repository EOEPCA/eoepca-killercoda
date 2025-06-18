As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us configuring and deploying our application. 

First, we download and uncompress the **eoepca-2.0-rc1b** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc1b | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

The Rescource Discovery deployment scripts are available in the `resource-discovery` directory:
```
cd deployment-guide/scripts/resource-discovery
```{{exec}}

Now we need to understand our pre-requisites. In general EOEPCA Building Blocks will require as minimal pre-requisite a Kubernetes cluster, with an ingress controller to expose the EOEPCA building block interfaces and DNS entries to map the EOEPCA interface endpoints. In this tutorial, for simplicity, nginx is already installed and the `*.eoepca.local` domain is mapped to the nginx address.

Next we need to check the specific Resource Discovery BB prerequisites for installing the Resource Discovery building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary pre-requirements are installed. 

EOEPCA components can work with or without certificates. We choose th `http` scheme since we are not using certificates and encryption for our tutorial:
```
http
```{{exec}}

EOEPCA components can work with different Ingress services installed in your Kubernetes cluster. The default configuration uses [apisix](https://apisix.apache.org/) to provide advanced authentication and authorization. For this demo environment, we will use the simpler nginx ingress without authorization

```
nginx
```{{exec}}

We enter the top-level domain for our EOEPCA services:
```
eoepca.local
```{{exec}}

We do not need a specific Storage Class for this component, so for this example we will use the basic storage class provided by Killercoda. Note that, in an operational environment, you should use a reliable (and possibly redundant and backed up) storage class, as this storage class will be used to store all the metadata of your data

```
local-path
```{{exec}}

We also do not need automatically generated certificates or indeed any certificates at all for our tutorial:
```
no
```{{exec}}

Now, all the pre-requisites should be met
