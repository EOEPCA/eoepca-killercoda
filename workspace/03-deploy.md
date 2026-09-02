We can now deploy the Workspace building block.

## Kubernetes Secrets

Kubernetes secrets are used to share the credentials that the Workspace services rely upon.

```bash
bash apply-secrets.sh
```{{exec}}

## Workspace Dependencies

The workspace dependencies include CSI-RClone for storage mounting and the Educates framework for workspace environments.

```bash
# Deploy Kyverno (required by Educates' own bundled ClusterPolicies, and reused
# later for the optional TLS/IAM workarounds in sections 8.2 and 9.3)
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update kyverno
helm upgrade -i kyverno kyverno/kyverno \
  --version 3.9.0 \
  --namespace kyverno \
  --create-namespace \
  --set backgroundController.enable=true

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

This deploys a CronJob that automatically cleans up inactive DataLab sessions - removing all sessions except the default ones.

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


## Keycloak Client for the Workspace API

Render and apply the `workspace-api` Keycloak client, with protocol mappers so its tokens carry an `aud` claim naming itself (the workspace-api app rejects tokens lacking this) and a `groups` claim (used to resolve workspace ownership/membership). This also creates an `admin` client role and a `workspace-admin` group granting it, with `KEYCLOAK_TEST_ADMIN` added as a member - the app itself checks this role (independent of any ingress-layer enforcement) to grant access across every workspace rather than just ones the caller owns:

```bash
source ~/.eoepca/state
gomplate -f workspace-api/iam-template.yaml -o workspace-api/generated-iam.yaml
kubectl apply -f workspace-api/generated-iam.yaml
```{{exec}}

> Note: the following two steps are typically not necessary in a production environment

For the `workspace-api` client, we use the 'external tutorial' hostname for the Workspace API client - as this is what will be used via the tutorial UI to access the service. First we calculate this:

```bash
source ~/.eoepca/state
WORKSPACE_EXT_API_HOST="$(
  sed "s#http://PORT#$(awk -v host="$INGRESS_HOST" '$0 ~ ("workspace-api." host) {print $1}' /tmp/assets/killercodaproxy)#" \
    /etc/killercoda/host
)"
echo "Workspace API external host: ${WORKSPACE_EXT_API_HOST}"
```{{exec}}

and now we patch the client created by the template to use it

```bash
kubectl patch client.openidclient.keycloak.m.crossplane.io -n iam-management ${WORKSPACE_API_CLIENT_ID} --patch-file /dev/stdin --type merge <<EOF
spec:
  forProvider:
    rootUrl: ${HTTP_SCHEME}://${WORKSPACE_EXT_API_HOST}
    baseUrl: ${HTTP_SCHEME}://${WORKSPACE_EXT_API_HOST}
    adminUrl: ${HTTP_SCHEME}://${WORKSPACE_EXT_API_HOST}
    validRedirectUris:
      - "/*"
      - "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/*"
EOF
```{{exec}}

**_Workspace API Ingress_**

```bash
kubectl apply -f workspace-api/generated-ingress.yaml
```{{exec}}

## Protect Datalab Sessions with Keycloak SSO

Session ingresses aren't otherwise IAM-protected - a Kyverno policy wraps every Datalab session `Ingress` with the same `workspace-api` OIDC client, so opening a session requires a valid Keycloak login.

Grant Kyverno permission to manage `ApisixPluginConfig` resources, then apply the session-protection policy:

```bash
kubectl apply -f workspace-dependencies/kyverno-rbac-apisixpluginconfig.yaml
kubectl apply -f workspace-dependencies/generated-workspace-session-iam-policy.yaml
```{{exec}}


## end


**_Assign Workspace `admin` role to user `eoepcaadmin`_**

The above ApisixRoute ingress enforces this OPA policy - which requires users to have the admin role in order to access certain endpoints (e.g. workspace creation).

Create the `admin` role in the `workspace-api` client...

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: role.keycloak.m.crossplane.io/v1alpha1
kind: Role
metadata:
  name: ${WORKSPACE_API_CLIENT_ID}-admin
  namespace: iam-management
spec:
  forProvider:
    name: admin
    realmId: ${REALM}
    clientIdRef:
      name: ${WORKSPACE_API_CLIENT_ID}
    description: "Admin role for ${WORKSPACE_API_CLIENT_ID} client"
  providerConfigRef:
    name: keycloak-provider-config
    kind: ProviderConfig
EOF
```{{exec}}

Assign the `admin` role to the `eoepcaadmin` user...

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: user.keycloak.m.crossplane.io/v1alpha1
kind: Roles
metadata:
  name: ${KEYCLOAK_TEST_ADMIN}-${WORKSPACE_API_CLIENT_ID}-admin
  namespace: iam-management
spec:
  forProvider:
    realmId: ${REALM}
    userIdRef:
      name: ${KEYCLOAK_TEST_ADMIN}
    roleIdsRefs:
      - name: ${WORKSPACE_API_CLIENT_ID}-admin
    exhaustive: false
  providerConfigRef:
    name: keycloak-provider-config
    kind: ProviderConfig
EOF
```{{exec}}

## User Workspace Ingress Patch

The Workspace BB creates user workspaces with their own ingress resources. However, these ingresses need to be patched to include the correct annotations for the Apisix ingress controller.

A Kyverno `ClusterPolicy` is used to automatically patch any newly created user workspace ingresses.

> Note that the Kyverno service was already installed as a prerequisite of this tutorial.

```bash
source ~/.eoepca/state
cat - <<EOF | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: workspace-ingress
spec:
  rules:
    - name: workspace-ingress-annotations
      match:
        resources:
          kinds:
            - Ingress
          name: "ws-*"
      mutate:
        patchStrategicMerge:
          metadata:
            annotations:
              +(apisix.ingress.kubernetes.io/use-regex): "true"
              +(k8s.apisix.apache.org/enable-cors): "true"
              +(k8s.apisix.apache.org/enable-websocket): "true"
              +(k8s.apisix.apache.org/upstream-read-timeout): "3600s"
EOF
```{{exec}}

This completes the deployment of the Workspace building block.
