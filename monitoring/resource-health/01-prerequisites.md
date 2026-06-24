
As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, we download and uncompress the **eoepca-2.0** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

Next, set up internal TLS for our EOEPCA services:
```
cd deployment-guide/scripts/internal-tls
bash setup-internal-tls.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary pre-requirements are installed.

EOEPCA components can work with different Ingress services installed in your Kubernetes cluster. The default configuration uses [apisix](https://apisix.apache.org/) to provide advanced authentication and authorization. For this demo environment, we will use the simpler nginx ingress without authorization:

```
nginx
```{{exec}}

The tutorial environment has already set the top-level domain to
`eoepca.local`. Keep the existing value:
```
n
```{{exec}}

Storage class:
```
local-path
```{{exec}}

We do not need automatically generated certificates for our tutorial:
```
no
```{{exec}}

This will install cert-manager and create the necessary secrets and cluster issuers for internal TLS communication.

Now navigate to the Resource Health deployment scripts:
```
cd ../resource-health
```{{exec}}


Use the Deployment Guide's dedicated script to check the Resource Health
prerequisites:
```
bash check-prerequisites.sh
```{{exec}}


All prerequisites should now be met.
