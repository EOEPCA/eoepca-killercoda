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
#TODO: Pull request for killercoda-dataaccess to eoepca-2.0-rc1b and then update the tarball here with an official release (e.g. eoepca-2.0-rc1c)
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc1b | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
curl -s -L https://github.com/EOEPCA/deployment-guide/tarball/killercoda-dataaccess | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

<!--
curl -s -L https://github.com/EOEPCA/deployment-guide/tarball/killercoda-dataaccess | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
-->

The Data Access deployment scripts are available in the `data-access` directory:
```
cd deployment-guide/scripts/data-access
```{{exec}}

Next, we check whether the prerequisites listed above for installing the Data Access building block are met. The Deployment Guide scripts provide a dedicated script for this task:
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

We do not need special storage classes for this component (e.g. ReadWriteMany), so we can use the standard `local-path` {{}} storage class provided within this sandbox environment

```
local-path
```{{exec}}

We also do not need automatically generated certificates or indeed any certificates at all for our tutorial:
```
no
```{{exec}}
