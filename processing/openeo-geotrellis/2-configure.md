We need now to configure the OpenEO building block. To do so, we can use the deployment guide via

```
bash configure-openeo.sh
```{{exec}}

This building block supports two possible backends for running the processing, a [Spark/Geotrellis](https://github.com/locationtech/geotrellis) backend and a [Dask](https://www.dask.org/) backend. In this demonstration, we'll use the GeoTrellis backend as it's more suitable for demonstration purposes.

```bash
geotrellis
```{{exec}}

We are then asked whether we want to update the base domain and persistent storage class that were configured in the prerequisite step. We do not need to, and can reply `no` to both questions.

```
no
no
```{{exec}}

We are now asked if we want to enable authentication using the [EOEPCA IAM](https://eoepca.readthedocs.io/projects/iam/en/latest/) component via its [OIDC Interface](https://openid.net/). For this demo, we will not use OIDC authentication, so we also reply

```
no
```{{exec}}

The deployment script has now generated the necessary configuration files for the deployment.
