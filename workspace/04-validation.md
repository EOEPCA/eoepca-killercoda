## Validation Script

A quick sanity check of the deployment is made via some automated checks...

```bash
bash validation.sh
```{{exec}}

## OpenAPI Endpoint

You can also verify the deployment by accessing the [OpenAPI endpoint]({{TRAFFIC_HOST1_81}}/docs) of the deployed service.

## Create a Workspace

You can create a new Workspace by calling the Workspace REST API.

### Obtain an Access Token

User `eoepcaadmin` was registered earlier as a Workspace admin user. Obtain an access token for this user:

```bash
source ~/.eoepca/state
# Authenticate as test admin `eoepcaadmin`
ACCESS_TOKEN=$( \
  curl -X POST "${HTTP_SCHEME}://auth.${INGRESS_HOST}/realms/${REALM}/protocol/openid-connect/token" \
    --silent --show-error \
    -d "username=${KEYCLOAK_TEST_ADMIN}" \
    --data-urlencode "password=${KEYCLOAK_TEST_PASSWORD}" \
    -d "grant_type=password" \
    -d "client_id=${WORKSPACE_API_CLIENT_ID}" \
    | jq -r '.access_token' \
)
echo "Access Token: ${ACCESS_TOKEN:0:20}..."
```{{exec}}

### Initiate Workspace Creation

Using the Workspace API, create a new workspace for the test user `eoepcauser`.

```bash
source ~/.eoepca/state
curl -X POST "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/workspaces" \
  --silent --show-error \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "preferred_name": "${KEYCLOAK_TEST_USER}",
  "default_owner": "${KEYCLOAK_TEST_USER}"
}
EOF
```{{exec}}

### Check Workspace Creation

Creation is asynchronous. Wait for Crossplane to provision storage, membership and the Datalab before authenticating as the owner:

```bash
kubectl wait --for=condition=Ready storage/ws-${KEYCLOAK_TEST_USER} datalab/ws-${KEYCLOAK_TEST_USER} -n workspace --timeout=10m
```{{exec}}

**Namespace...**

```bash
source ~/.eoepca/state
kubectl get ns ws-${KEYCLOAK_TEST_USER}
```{{exec}}

**Custom Resources...**

```bash
kubectl get storage/ws-${KEYCLOAK_TEST_USER} datalab/ws-${KEYCLOAK_TEST_USER} -n workspace
```{{exec}}

**Resources provisioned for the workspace...**

Crossplane creates the workspace's object storage and its Keycloak client, roles and
groups from those two custom resources:

```bash
kubectl get buckets,users -n workspace
kubectl get clients,roles.role.keycloak.m.crossplane.io,groups.group.keycloak.m.crossplane.io -n workspace
```{{exec}}

The `Bucket` and `User` are the workspace's object storage and the S3 credentials
returned below. Access is shared through the Keycloak groups: members of `ws-eoepcauser`
hold the `ws_access` role of the `ws-eoepcauser` client, and members of `ws-eoepcauser-admin`
hold `ws_admin`. The owner, `eoepcauser`, is a member of both.

### Get Workspace Details

Authenticate as `eoepcauser` - the owner of the newly created workspace

```bash
source ~/.eoepca/state
ACCESS_TOKEN=$( \
  curl -X POST "${HTTP_SCHEME}://auth.${INGRESS_HOST}/realms/${REALM}/protocol/openid-connect/token" \
    --silent --show-error \
    -d "username=${KEYCLOAK_TEST_USER}" \
    --data-urlencode "password=${KEYCLOAK_TEST_PASSWORD}" \
    -d "grant_type=password" \
    -d "client_id=${WORKSPACE_API_CLIENT_ID}" \
    | jq -r '.access_token' \
)
echo "Access Token: ${ACCESS_TOKEN:0:20}..."
```{{exec}}

Call the Workspace API to get details for the newly created workspace

```bash
source ~/.eoepca/state
curl -X GET "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/workspaces/ws-${KEYCLOAK_TEST_USER}" \
  --silent --show-error \
  -H "Accept: application/json" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  | jq
```{{exec}}

In the response:

* `status` is `ready`
* `storage.credentials` holds the S3 access key and secret for the workspace bucket
* `datalab.sessions` lists the `default` session, which is `stopped`
* `user.permissions` lists what the owner may do, such as `MANAGE_BUCKETS` and `MANAGE_SESSIONS`
