Next, run the Deployment Guide configuration script:

```
bash configure-openeo.sh
```{{exec}}

The Processing Building Block supports a [Spark/GeoTrellis](https://github.com/locationtech/geotrellis) backend and a [Dask](https://www.dask.org/) backend. Select GeoTrellis for this workshop:

```bash
geotrellis
```{{exec}}

Keep the base domain and persistent storage class configured in the prerequisite step by answering `no` to both update prompts:

```
no
no
```{{exec}}

The final prompt offers authentication through the [EOEPCA IAM](https://eoepca.readthedocs.io/projects/iam/en/latest/) component using [OIDC](https://openid.net/). This self-contained workshop uses the backend's demo basic authentication instead, so disable OIDC:

```
no
```{{exec}}

The script uses the shared state in `~/.eoepca/state` to generate:

- `sparkoperator/generated-values.yaml`
- `zookeeper/generated-values.yaml`
- `openeo-geotrellis/generated-values.yaml`
- `openeo-geotrellis/generated-ingress.yaml`

The next steps pass these generated files directly to Helm and `kubectl`. The OpenEO image tag and pull policy are overridden only in the deployment command to use the Localcoda-compatible image prepared later in this tutorial.
