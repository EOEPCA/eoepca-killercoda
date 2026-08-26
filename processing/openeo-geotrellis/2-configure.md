Next, run the Deployment Guide configuration script. This script is specific to the
[Spark/GeoTrellis](https://github.com/locationtech/geotrellis) backend - the
[Dask](https://www.dask.org/) backend lives in the separate OpenEO ArgoWorkflows building
block, with its own scripts:

```
bash configure-openeo.sh
```{{exec}}

The only question it asks is whether to enable authentication through the [EOEPCA IAM](https://eoepca.readthedocs.io/projects/iam/en/latest/) component using [OIDC](https://openid.net/). This self-contained workshop uses the backend's demo basic authentication instead, so disable OIDC:

```
no
```{{exec}}

The script uses the shared state in `~/.eoepca/state` to generate:

- `sparkoperator/generated-values.yaml`
- `zookeeper/generated-values.yaml`
- `openeo-geotrellis/generated-values.yaml`
- `openeo-geotrellis/generated-ingress.yaml`

The next steps pass these generated files directly to Helm and `kubectl`. The OpenEO image tag and pull policy are overridden only in the deployment command to use the Localcoda-compatible image prepared later in this tutorial.
