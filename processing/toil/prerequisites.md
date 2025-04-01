As ususal in this tutorial, we will use the EOEPCA deployment-guide scripts to help us configuring and deploying our application. Let's clone it in our environment

```
git clone https://github.com/EOEPCA/deployment-guide
```{{exec}}

the OGC API Process interface deployment scripts are available in the `processing/oapip` directory, let's open it

```
cd ~/deployment-guide/scripts/processing/oapip
git checkout killercoda-demo
```{{exec}}

As specified in the deployment guide, the OGC API Process interface, Calrissian Kubernetes engine, requires the following pre-requisites:
 - a kubernetes cluster
 - an S3 object storage
 - an HPC cluster interface (Toil supports [several](https://toil.readthedocs.io/en/latest/running/hpcEnvironments.html))
 - a working Toil instance and [Toil WES service](https://toil.readthedocs.io/en/master/running/server/wes.html) installed on the HPC cluster

we will check in the next steps the avaliability of these pre-requisites
