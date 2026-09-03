We will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, we clone the **release-2.1** branch of the EOEPCA Deployment Guide, to which this tutorial refers:

<!-- TODO(release-2.1): once the eoepca-2.1 tag is published, revert this step to the tarball
     download used elsewhere: curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.1
     | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|' -->
```
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
```{{exec}}

This tutorial registers all resources into the **Data Access** Building Block's STAC API, deployed in the next step.

The Resource Registration deployment scripts are available in the `resource-registration` directory:
```
cd ~/deployment-guide/scripts/resource-registration
```{{exec}}

Next we need to check the Resource Registration BB prerequisites are met. The Deployment Guide scripts provide a dedicated script for this task. As this is the first deployment guide script run in this tutorial, it also asks for some shared configuration first:

```
bash check-prerequisites.sh
```{{exec}}

We keep the pre-configured base domain, and choose `local-path` as the storage class for non-shared data and no automatic TLS certificate issuance:

```
n
local-path
no
```{{exec}}

Now, all the pre-requisites should be met.
