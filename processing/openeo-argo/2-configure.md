## Configuration

Configure OpenEO ArgoWorkflows for deployment. This setup uses simplified authentication for demonstration purposes.

```bash
bash configure-openeo-argo.sh <<EOF
eoepca.local
local-path
none
http://stac.eoepca.local/stac
mock
demo
EOF
```{{exec}}


The configuration generates values for PostgreSQL, Redis, and the OpenEO API service.