
We create a dedicated realm for EOEPCA in Keycloak to manage our users and clients.

This is performed via the Keycloak REST API,as the `admin`{{}} user that was established via helm values during Keycloak deployment.

## Obtain Access Token

First step is to obtain an access token using the `admin`{{}} user credentials.

```bash
source ~/.eoepca/state
ACCESS_TOKEN=$( \
  curl -X POST "${HTTP_SCHEME}://auth.${INGRESS_HOST}/realms/master/protocol/openid-connect/token" \
    --silent --show-error \
    -d "username=${KEYCLOAK_ADMIN_USER}" \
    --data-urlencode "password=${KEYCLOAK_ADMIN_PASSWORD}" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" \
    | jq -r '.access_token' \
)
if [ $? -eq 0 -a -n "$ACCESS_TOKEN" -a "$ACCESS_TOKEN" != "null" ]; then
  echo "Access Token: ${ACCESS_TOKEN:0:20}..."
else
  echo "Error obtaining access token"
fi
```{{exec}}

## Create EOEPCA Realm

The realm is created by sending a POST request to the Keycloak Admin REST API with the realm configuration in JSON format.

```bash
source ~/.eoepca/state
curl -X POST "${HTTP_SCHEME}://auth.${INGRESS_HOST}/admin/realms" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d @- <<EOF
{
  "realm": "${REALM}",
  "enabled": true,
  "displayName": "EOEPCA"
}
EOF
```{{exec}}

## Check the new EOEPCA Realm

The new realm can be checked by querying the OpenID configuration endpoint for the realm.

```bash
curl -k http://auth.eoepca.local/realms/eoepca/.well-known/openid-configuration | jq
```{{exec}}
