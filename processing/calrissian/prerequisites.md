Clone the `release-2.1` branch of the [EOEPCA Deployment Guide](https://github.com/EOEPCA/deployment-guide):

```
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
```{{exec}}

Open the OGC API Processes deployment scripts:

```
cd ~/deployment-guide/scripts/processing/oapip
```{{exec}}

The next steps check the Kubernetes cluster, ReadWriteMany storage and S3 object store supplied by this tutorial.
