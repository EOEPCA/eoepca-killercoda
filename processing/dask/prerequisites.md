
As usual in this tutorial, we'll use the [EOEPCA deployment-guide scripts](https://github.com/EOEPCA/deployment-guide) to help us configure and deploy our application.

First, we download and uncompress the **eoepca-2.0-rc1b** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```bash
git clone https://github.com/EOEPCA/deployment-guide
cd deployment-guide/scripts/processing/openeo
```

As specified in the deployment guide, the OpenEO API interface with Dask backend requires the following pre-requisites:
- A Kubernetes cluster with sufficient resources
- A Dask Gateway deployment for managing Dask clusters
- An S3 object storage for data access and result storage
- STAC catalog endpoints for EO data discovery (optional but recommended)

We'll check the availability of these pre-requisites in the next steps.