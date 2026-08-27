## Configure OpenEO ArgoWorkflows

Run the configuration script:

```bash
bash configure-openeo-argo.sh <<EOF
n
n
eoepca

http://resource-catalogue.eoepca.local/stac
EOF
```{{exec}}

Run each answer only when its corresponding prompt appears:

1. `SHARED_STORAGECLASS` is already `standard` - keep it: `n`
2. `OIDC_ISSUER_URL` is already set to this cluster's Keycloak - keep it: `n`
3. `OIDC_ORGANISATION`, the realm identifier used in the bearer token format: `eoepca`
4. `OIDC_POLICIES` - optional, leave empty
5. `STAC_CATALOG_ENDPOINT` - we'll deploy the EOEPCA Resource Discovery Building Block as this backend's STAC source in the next step: `http://resource-catalogue.eoepca.local/stac`

Review the important generated values:

```bash
grep -E \
  'apiDns:|oidcUrl:|oidcOrganisation:|stacCatalogueUrl:|workspaceRoot:' \
  generated-values.yaml
```{{exec}}
