
## Configuration

Configure OpenEO ArgoWorkflows for deployment. This setup uses simplified authentication for demonstration purposes.

```bash
bash configure-openeo-argo.sh <<EOF
eoepca.local
local-path
no
http://stac.eoepca.local/stac
EOF
```{{exec}}

Update the OIDC URL to use the internal cluster DNS:

```bash
sed -i 's|dummy-oidc.local|dummy-oidc-local.openeo.svc.cluster.local|g' generated-values.yaml
```{{exec}}

The configuration generates values for PostgreSQL, Redis, and the OpenEO API service.