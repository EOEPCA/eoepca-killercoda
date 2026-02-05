## Prerequisites and Initial Setup

First, let's download the latest deployment-guide repository which contains the necessary scripts.

```bash
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
cd deployment-guide/scripts/processing/openeo
```{{exec}}

Next we need to check the specific Resource Discovery BB prerequisites for installing the Resource Discovery building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary pre-requirements are installed.

EOEPCA components can work with different Ingress services installed in your Kubernetes cluster. The default configuration uses [apisix](https://apisix.apache.org/) to provide advanced authentication and authorization. For this demo environment, we will use the simpler nginx ingress without authorization

```
nginx
```{{exec}}

We enter the top-level domain for our EOEPCA services:
```
eoepca.local
```{{exec}}

We do not need a specific Storage Class for this component, so for this example we will use the basic storage class provided in this sandbox. Note that, in an operational environment, you should use a reliable (and possibly redundant and backed up) storage class, as this storage class will be used to store all the metadata of your data

```
local-path
```{{exec}}

We also do not need automatically generated certificates or indeed any certificates at all for our tutorial:
```
no
```{{exec}}

Now, all the pre-requisites should be met. If you want to know more abot the pre-requisites above, you can follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial.
