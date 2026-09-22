## Explore the OpenEO API

Get an access token from Keycloak using the `openeo-argo` client, and wrap it in the `oidc/<organisation>/<token>` bearer format this backend expects:

```bash
source ~/.eoepca/state

ACCESS_TOKEN=$(curl -s -X POST \
    "${OIDC_ISSUER_URL}/protocol/openid-connect/token" \
    -d "grant_type=password" \
    -d "username=${KEYCLOAK_TEST_USER}" \
    -d "password=${KEYCLOAK_TEST_PASSWORD}" \
    -d "client_id=openeo-argo" \
    -d "scope=openid" | jq -r '.access_token')
export AUTH_TOKEN="oidc/${OIDC_ORGANISATION}/${ACCESS_TOKEN}"
export OPENEO_URL="http://openeo-argo.eoepca.local/openeo/1.1.0"
```{{exec}}

Inspect the API capabilities:

```bash
curl -fsS "${OPENEO_URL}/" | jq '{title, api_version, backend_version}'
```{{exec}}

Check that the token is valid on a protected endpoint:

```bash
curl -fsS -H "Authorization: Bearer ${AUTH_TOKEN}" "${OPENEO_URL}/me" | jq .
```{{exec}}

List the collections exposed through OpenEO, including the `sentinel-2-demo` collection we registered in Resource Discovery:

```bash
curl -fsS "${OPENEO_URL}/collections" | jq '.collections[].id'
```{{exec}}

Inspect our sample collection:

```bash
curl -fsS "${OPENEO_URL}/collections/sentinel-2-demo" \
  | jq '{id, title, extent}'
```{{exec}}

Finally, list the processes this backend advertises - `ndvi`, used in the next step, is one of them:

```bash
curl -fsS "${OPENEO_URL}/processes" | jq '[.processes[].id] | sort'
```{{exec}}

These are the same discovery endpoints used by OpenEO clients (such as the Python client or the Web Editor) to build and validate process graphs.

