As usual in this tutorial, we will use the [EOEPCA deployment-guide scripts](https://github.com/EOEPCA/deployment-guide) to help us configuring and deploying our application.

First, we clone the **release-2.1** branch of the EOEPCA Deployment Guide, to which this tutorial refers:

<!-- TODO(release-2.1): once the eoepca-2.1 tag is published, revert this step to the tarball
     download: curl --fail --location --show-error https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.1
     | tar xz --transform 's|^EOEPCA[^/]*|deployment-guide|' -->
```
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
```{{exec}}

We also need to install uuidgen:

```
sudo apt-get install -y uuid-runtime
```{{exec}}

Localcoda has already installed Docker as part of the HTCondor setup. Run the compatibility helper before starting nested application containers:

Only run this command if you are using the tutorial virtual machine. 

```
sudo /tmp/assets/prepare-docker-runtime
```{{exec}}

The OGC API Process interface deployment scripts are available in the `processing/oapip` directory, let's open it:

```
cd ~/deployment-guide/scripts/processing/oapip
```{{exec}}

As specified in the deployment guide, the OGC API Process interface with the Toil HPC engine requires the following pre-requisites:

- a Kubernetes cluster
- a Read-Write-Many Storage Class (a pre-requisite for Zoo)
- an S3 object storage
- an HPC cluster offering the [Toil WES service](https://toil.readthedocs.io/en/master/running/server/wes.html), or in alternative an HPC cluster with an interface [supported by Toil](https://toil.readthedocs.io/en/latest/running/hpcEnvironments.html)

We will check in the next steps the availability of these pre-requisites.
