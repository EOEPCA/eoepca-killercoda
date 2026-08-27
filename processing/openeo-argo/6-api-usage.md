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
curl -fsS "${OPENEO_URL}/" \
  | jq '{
      title,
      api_version,
      backend_version,
      endpoint_count: (.endpoints | length)
    }'
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

Finally, summarize the available processes:

```bash
curl -fsS "${OPENEO_URL}/processes" \
  | jq '{
      count: (.processes | length),
      examples: [.processes[0:10][].id]
    }'
```{{exec}}

These are the same discovery endpoints used by OpenEO clients (such as the Python client or the Web Editor) to build and validate process graphs.

### OpenEO Web Editor

You can also connect the public [OpenEO Web Editor](https://editor.openeo.org) to this backend from your own browser:

```
https://editor.openeo.org?server={{TRAFFIC_HOST1_81}}/openeo/1.1.0/
```

Select `EOEPCA` and log in via the IAM Keycloak instance with `eoepcauser`{{copy}} / `eoepcapassword`{{copy}}.
