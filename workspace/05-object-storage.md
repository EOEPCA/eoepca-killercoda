Each workspace has a dedicated S3 bucket. Use the workspace owner's credentials to upload a small sample of vegetation-index observations, and add a second bucket for results. The next step processes the sample in the Datalab.

## Get Storage Credentials

Authenticate as the workspace owner:

```bash
source ~/.eoepca/state
ACCESS_TOKEN=$(
  curl --silent --show-error --fail \
    "${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/token" \
    -d "username=${KEYCLOAK_TEST_USER}" \
    --data-urlencode "password=${KEYCLOAK_TEST_PASSWORD}" \
    -d "grant_type=password" \
    -d "client_id=${WORKSPACE_API_CLIENT_ID}" \
    | jq -r '.access_token'
)
WORKSPACE_DETAILS=$(
  curl --silent --show-error --fail \
    "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/workspaces/ws-${KEYCLOAK_TEST_USER}" \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}"
)
ACCESS_KEY=$(echo "$WORKSPACE_DETAILS" | jq -r '.storage.credentials.access')
SECRET=$(echo "$WORKSPACE_DETAILS" | jq -r '.storage.credentials.secret')
BUCKET=$(echo "$WORKSPACE_DETAILS" | jq -r '.storage.credentials.bucketname')
```{{exec}}

The access key is a generated storage account, not the Keycloak username.

## Connect to the Bucket

Configure the MinIO client with the workspace credentials and the configured storage endpoint:

```bash
mc alias set mystorage "$S3_ENDPOINT" "$ACCESS_KEY" "$SECRET"
mc ls "mystorage/$BUCKET"
```{{exec}}

## Upload Sample Observations

A small CSV of vegetation-index readings is enough to exercise the storage and the Datalab:

```bash
cat > observations.csv <<'EOF'
site,ndvi
field-a,0.2
field-b,0.5
field-c,0.8
EOF
mc cp observations.csv "mystorage/$BUCKET/observations.csv"
mc ls "mystorage/$BUCKET"
```{{exec}}

The listing should contain `observations.csv`. Leave it in the bucket - the next step reads it from the Datalab.

## Storage Isolation

The credentials only give access to this workspace's buckets. Try to list the platform's `eoepca` bucket:

```bash
mc ls mystorage/eoepca
```{{exec}}

MinIO answers `Access Denied`.

## Add a Bucket

The workspace owner can add buckets through the Workspace API. Add one to hold processing results:

```bash
curl --silent --show-error -X PUT \
  "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/workspaces/ws-${KEYCLOAK_TEST_USER}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"add_buckets": [{"name": "ws-eoepcauser-results"}]}' | jq
```{{exec}}

Crossplane creates the bucket and adds it to the workspace's storage policy:

```bash
kubectl -n workspace wait --for=create bucket/ws-eoepcauser-results --timeout=1m
kubectl -n workspace wait --for=condition=Ready bucket/ws-eoepcauser-results --timeout=2m
mc ls mystorage
```{{exec}}

Both `ws-eoepcauser` and `ws-eoepcauser-results` are listed, using the same credentials. If the new bucket is missing, run `mc ls mystorage`{{exec}} again after a few seconds - its access policy is attached to the workspace credentials just after the bucket is ready.
