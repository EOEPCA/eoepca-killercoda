Before deploying the Data Access Building Block, we must have the following software and tools:
- Kubernetes >= 1.28
- Helm >= 3.5
- `kubectl` with context set to your cluster
- Ingress controller (e.g., APISIX or nginx)
- TLS issuer (e.g., cert-manager)
- S3-compatible object storage (e.g., MinIO)

Of these, Kubernetes, Helm and `kubectl` command come preinstalled on the KillerCoda platform, nginx ingress controller and minio S3 object storage have already been installed as prerequisites and we won't be using TLS certificates and encryption therefore we do not need cert-manager.

As ususal in this tutorial, we will use the EOEPCA Deployment Guide scripts to help us configuring and deploying our application. 

We download and uncompress the **eoepca-2.0-rc1b** version of the EOEPCA Deployment Guide, to which this tutorial refers. This contains the deployment scripts we will use for our EOEPCA deployment
```
curl -s -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc1b | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

<!--
First, we clone it in our environment:
```
git clone https://github.com/EOEPCA/deployment-guide
```{{exec}}
-->

The Rescource Catalogue deployment scripts are available in the `resource-discovery` directory:
```
cd deployment-guide/scripts/data-access
```{{exec}}

Next, we check whether the prerequisites listed above for installing the Resource Discovery building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary prerequirements are installed. 

First, we choose th `http` scheme since we are not using certificates and encryption for our tutorial:
```
http
```{{exec}}

We choose the nginx ingress controller:
```
nginx
```{{exec}}

We enter the top-level domain for our EOEPCA services:
```
eoepca.local
```{{exec}}

We use the default storage class, already configured in our Kubernetes cluster and selected as default for our EOEPCA deployment:
```
standard
```{{exec}}

We also do not need automatically generated certificates or indeed any certificates at all for our tutorial:
```
no
```{{exec}}
