## Configure OpenEO ArgoWorkflows

Generate the OpenEO values and ingress manifests. Use the shared job workspace storage class,
point at a placeholder OIDC issuer for the in-cluster mock provider we'll fix up next, and
point OpenEO at the Resource Discovery STAC API that we will deploy later:

```bash
bash configure-openeo-argo.sh <<EOF
standard
http://dummy-oidc.local/realms/eoepca
eoepca

http://resource-catalogue.eoepca.local/stac
EOF
```{{exec}}

For this workshop, a small in-cluster OIDC provider will validate the demo user's token. Replace the placeholder issuer hostname with its Kubernetes service name:

```bash
sed -i \
  's|dummy-oidc.local|dummy-oidc-local.openeo.svc.cluster.local|g' \
  generated-values.yaml
```{{exec}}

Review the important generated values:

```bash
grep -E \
  'apiDns:|oidcUrl:|stacCatalogueUrl:|workspaceRoot:|executorImage:' \
  generated-values.yaml
```{{exec}}
