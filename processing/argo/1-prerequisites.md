As usual in this tutorial, we will use the [EOEPCA deployment-guide scripts](https://github.com/EOEPCA/deployment-guide) to help us configuring and deploying our application.

First, we download and uncompress the **eoepca-2.0-rc1b** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc1b | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

---

__DEV ONLY__

```
git clone https://github.com/EOEPCA/deployment-guide.git -b killercoda-jh-changes
```

the OGC API Process interface deployment scripts are available in the `processing/oapip` directory, let's open it

```
cd \~/deployment-guide/scripts/processing/oapip
```{{exec}}

As specified in the deployment guide, the OGC API Process interface, Argo Workflows engine, requires the following pre-requisites:
 - a kubernetes cluster
 - a Read-Write-Many Storage Class (a pre-requisite for Zoo)
 - an S3 object storage

we will check in the next steps the avaliability of these pre-requisites
