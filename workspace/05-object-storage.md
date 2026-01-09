Each new Workspace is created with a dedicated S3-compatible object storage bucket. In this section, we will connect to that object storage and perform some basic operations.

## Get Storage Credentials

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
    -d "client_secret=${WORKSPACE_API_CLIENT_SECRET}" \
    | jq -r '.access_token' \
)
echo "Access Token: ${ACCESS_TOKEN:0:20}..."
```{{exec}}

Record the storage credentials from the 'Get Workspace Details' response

```bash
source ~/.eoepca/state
SECRET=$( \
  curl -X GET "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/workspaces/ws-${KEYCLOAK_TEST_USER}" \
    --silent --show-error \
    -H "Accept: application/json" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    | jq -r '.storage.credentials.secret'
)
echo "S3 Secret: ${SECRET}"
```{{exec}}

## Use the MinIO Client `mc`

Using the retrieved secret, configure the MinIO client alias `mystorage` to access the user's workspace object storage...

```bash
mc alias set mystorage http://minio.eoepca.local:9000 eoepcauser "$SECRET"
```{{exec}}

## Check the workspace bucket

List the contents of the object storage...

```bash
mc ls mystorage
```{{exec}}

> The bucket `ws-eoepcauser` is shown to exist, but is currently empty.

```bash
mc ls mystorage/ws-eoepcauser
```{{exec}}

## Check file upload

Upload a test file...

> Assumes the working directory `scripts/workspace`

```bash
mc cp validation.sh mystorage/ws-eoepcauser
```{{exec}}

Check the uploaded file...

```bash
mc ls mystorage/ws-eoepcauser
```{{exec}}

## Check file download

Download the test file...

```bash
mc cp mystorage/ws-eoepcauser/validation.sh downloaded-validation.sh
ls -l downloaded-validation.sh
```{{exec}}

## Cleanup

Remove the test file...

```bash
mc rm mystorage/ws-eoepcauser/validation.sh
rm downloaded-validation.sh
```{{exec}}
