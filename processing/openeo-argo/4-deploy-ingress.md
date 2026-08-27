## Deploy Ingress and Configure Authentication

### Deploy the ingress

```bash
kubectl apply -f generated-ingress.yaml
```{{exec}}

### Create the Keycloak client

The OpenEO API validates OIDC bearer tokens itself, so it needs a Keycloak client to check tokens against. `configure-openeo-argo.sh` already rendered `generated-iam.yaml` - a Crossplane `Client` CRD for the client, plus a `ClientDefaultScopes` override so its tokens carry the `profile`/`email`/`roles`/`basic` scopes:

```bash
kubectl apply -f generated-iam.yaml
kubectl wait --for=condition=Ready client.openidclient.keycloak.m.crossplane.io/openeo-argo -n iam-management --timeout=60s
```{{exec}}

Check the API and ingress:

```bash
kubectl get pods -n openeo
kubectl get ingress -n openeo
```{{exec}}

Wait for the API to answer through the ingress. This endpoint is public, so no token is needed yet:

```bash
while [[ $(curl -s -o /dev/null -w "%{http_code}" -L http://openeo-argo.eoepca.local/openeo/1.1.0) != 200 ]]; do sleep 5; done
curl -s -L http://openeo-argo.eoepca.local/openeo/1.1.0 | jq '{title, api_version, backend_version}'
```{{exec}}

The OpenEO ingress is also available through the Localcoda proxy at [this link]({{TRAFFIC_HOST1_81}}).
