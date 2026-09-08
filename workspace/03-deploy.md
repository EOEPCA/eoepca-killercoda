We can now deploy the Workspace building block.

## Kubernetes Secrets

Kubernetes secrets are used to share the credentials that the Workspace services rely upon.

```bash
bash apply-secrets.sh
```{{exec}}

## Workspace Dependencies

The workspace dependencies include CSI-RClone for storage mounting and the Educates framework for workspace environments.

```bash
# Educates and the session ingress policies require Kyverno.
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update kyverno
helm upgrade -i kyverno kyverno/kyverno \
  --version 3.9.0 \
  --namespace kyverno \
  --create-namespace \
  --set backgroundController.enabled=true \
  --wait --timeout=5m

# Deploy CSI-RClone
helm upgrade -i workspace-dependencies-csi-rclone \
  oci://ghcr.io/eoepca/workspace/workspace-dependencies-csi-rclone \
  --version 2.2.0 \
  --namespace workspace

# Deploy Educates
helm upgrade -i workspace-dependencies-educates \
  oci://ghcr.io/eoepca/workspace/workspace-dependencies-educates \
  --version 2.2.0 \
  --namespace workspace \
  --values workspace-dependencies/educates-values.yaml
```{{exec}}

Educates gives every Datalab session's own registry component a per-session `Ingress`, but doesn't set an `ingressClassName` on it - so on an APISIX-only cluster it's created but never actually routable. Apply a Kyverno policy to fix this on every session:

```bash
kubectl apply -f workspace-dependencies/kyverno-registry-ingress-class.yaml
```{{exec}}

## Workspace API

The Workspace API provides a REST interface for administration of workspaces.

```bash
helm repo add eoepca https://eoepca.github.io/helm-charts
helm repo update eoepca
helm upgrade -i workspace-api eoepca/rm-workspace-api \
  --version 2.2.2 \
  --namespace workspace \
  --values workspace-api/generated-values.yaml
```{{exec}}

## Workspace Pipeline

The Workspace Pipeline manages the templating and provisioning of resources within newly created workspaces.

```bash
helm upgrade -i workspace-pipeline \
  oci://ghcr.io/eoepca/workspace/workspace-pipeline \
  --version 2.2.0 \
  --namespace workspace \
  --values workspace-pipeline/generated-values.yaml
```{{exec}}

## DataLab Session Cleaner

This deploys a CronJob that stops all Datalab sessions daily at 20:00 UTC, including the default session. Their configuration is preserved so they can be started again.

```bash
kubectl apply -f workspace-cleanup/datalab-cleaner.yaml
```{{exec}}

## Crossplane Provider Configurations

Each Crossplane provider used by the Workspace BB needs a `ProviderConfig` in the `workspace` namespace (the MinIO provider is the exception - already configured cluster-wide in the Crossplane prerequisites):

```bash
kubectl apply -f workspace-dependencies/provider-configs.yaml
```{{exec}}

## Keycloak Client for Workspace Pipeline

The workspace pipeline needs its own Keycloak client, `workspace-pipeline`, so it can self-serve a Keycloak client/roles/groups for every workspace it provisions.

Look up the UUID of Keycloak's built-in `realm-management` client (adopted below, since role grants reference it and it isn't created by the IAM Building Block itself):

```bash
source ~/.eoepca/state
KEYCLOAK_ADMIN_TOKEN=$( \
  curl -X POST "${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/master/protocol/openid-connect/token" \
    --silent --show-error \
    -d "client_id=admin-cli" -d "grant_type=password" \
    -d "username=${KEYCLOAK_ADMIN_USER}" --data-urlencode "password=${KEYCLOAK_ADMIN_PASSWORD}" \
    | jq -r '.access_token' \
)
export REALM_MANAGEMENT_CLIENT_UUID=$( \
  curl --silent --show-error -H "Authorization: Bearer ${KEYCLOAK_ADMIN_TOKEN}" \
    "${HTTP_SCHEME}://${KEYCLOAK_HOST}/admin/realms/${REALM}/clients?clientId=realm-management" \
    | jq -r '.[0].id' \
)
```{{exec}}

Render and apply the `workspace-pipeline` client, the adopted `realm-management` client, and the `realm-management` role grants it needs (`manage-users`, `manage-authorization`, `manage-clients`, `create-client`, and the composite `realm-admin` - required because the Keycloak Terraform provider Crossplane uses calls the realm's `serverinfo` admin endpoint on every connection, which only `realm-admin` can reach):

```bash
source ~/.eoepca/state
gomplate -f workspace-dependencies/pipeline-iam-template.yaml -o workspace-dependencies/generated-pipeline-iam.yaml
kubectl apply -f workspace-dependencies/generated-pipeline-iam.yaml
```{{exec}}


## TLS Certificate for Datalab Sessions

Each Datalab session ingress references a `workspace-tls` secret in the `workspace` namespace, which Educates copies into the session namespace. APISIX drops an ingress whose TLS secret is missing, so create it before the first workspace.

The session ingress uses the internal `eoepca.local` domain, so use a self-signed certificate:

```bash
source ~/.eoepca/state
openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
  -keyout /tmp/workspace-tls.key -out /tmp/workspace-tls.crt \
  -subj "/CN=*.${INGRESS_HOST}" \
  -addext "subjectAltName=DNS:*.${INGRESS_HOST}"
kubectl -n workspace create secret tls workspace-tls \
  --cert=/tmp/workspace-tls.crt --key=/tmp/workspace-tls.key
```{{exec}}

## Keycloak Client for the Workspace API

Render and apply the `workspace-api` Keycloak client, with protocol mappers so its tokens carry an `aud` claim naming itself (the workspace-api app rejects tokens lacking this) and a `groups` claim (used to resolve workspace ownership/membership). This also creates an `admin` client role and a `workspace-admin` group granting it, with `KEYCLOAK_TEST_ADMIN` added as a member - the app itself checks this role (independent of any ingress-layer enforcement) to grant access across every workspace rather than just ones the caller owns:

```bash
source ~/.eoepca/state
gomplate -f workspace-api/iam-template.yaml -o workspace-api/generated-iam.yaml
kubectl apply -f workspace-api/generated-iam.yaml
```{{exec}}

**_Workspace API Ingress_**

```bash
kubectl apply -f workspace-api/generated-ingress.yaml
```{{exec}}

## Protect Datalab Sessions with Keycloak SSO

The Kyverno policy adds Keycloak login and the IAM OPA policy `eoepca/workspace/wsui` to each Datalab session ingress. The policy checks the user's workspace access or administrator role.

Grant Kyverno permission to manage `ApisixPluginConfig` resources, then apply the session-protection policy:

```bash
kubectl apply -f workspace-dependencies/kyverno-rbac-apisixpluginconfig.yaml
kubectl apply -f workspace-dependencies/generated-workspace-session-iam-policy.yaml
```{{exec}}


This completes the deployment of the Workspace building block.
