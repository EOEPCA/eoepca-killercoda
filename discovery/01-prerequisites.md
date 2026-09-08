As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/) scripts to help us in configuring and deploying our application.

First, we clone the **release-2.1** branch of the EOEPCA Deployment Guide, to which this tutorial refers:

<!-- TODO(release-2.1): once the eoepca-2.1 tag is published, revert this step to the tarball
     download used elsewhere: curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.1
     | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|' -->
```
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
```{{exec}}

The Resource Discovery deployment scripts are available in the `resource-discovery` directory:
```
cd deployment-guide/scripts/resource-discovery
```{{exec}}

Now we need to understand our pre-requisites. In general EOEPCA Building Blocks will require as a minimum pre-requisite a Kubernetes cluster, with an ingress controller to expose the EOEPCA building block interfaces and DNS entries to map the EOEPCA interface endpoints. Building Blocks which expose APIs for modifying data, such as adding entries to the resource catalogue, also require some form of authentication and authorization.

This tutorial uses the IAM Building Block and Keycloak for access control and the APISIX ingress controller for its OIDC integration with Keycloak.

You can also install the Resource Discovery Building Block as a read-only catalogue, in which case the IAM Building Block is not required. You might then use the Resource Registration Building Block to bulk import (meta)data.

Next we need to check the specific Resource Discovery BB prerequisites for installing the Resource Discovery building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

This is the first Deployment Guide script run in this tutorial, so it will also ask a few questions to establish the shared EOEPCA configuration (domain, storage class, TLS) used by every building block. The ingress class question is skipped because APISIX has already been selected for you by the tutorial environment.

> Some configuration has already been established by the startup scripts of the tutorial environment. In these cases we can answer `n`{{}} to accept the current value.

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

The pre-requisites should now be met. You can see the running components with

```
kubectl get pods -A
```{{exec}}

APISIX has already been deployed and configured to use *.eoepca.local hostnames without TLS. Keycloak has been deployed and an `eoepca` realm imported into it. We will use the Crossplane Keycloak provider later to create roles and users able to write to the resource catalogue.
