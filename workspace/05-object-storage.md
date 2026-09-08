Each workspace has a dedicated S3 bucket. Use the workspace owner's credentials to upload a small sample of vegetation-index observations, then read it from the Datalab in the next step.

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

These three illustrative observations are enough to exercise the storage and development environment:

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

The listing should contain `observations.csv`.

## Download and Compare

```bash
mc cp "mystorage/$BUCKET/observations.csv" downloaded-observations.csv
diff observations.csv downloaded-observations.csv
rm downloaded-observations.csv
```{{exec}}

No output from `diff` means that the downloaded data matches the original. Leave the object in the bucket - the next step reads it from the Datalab.
