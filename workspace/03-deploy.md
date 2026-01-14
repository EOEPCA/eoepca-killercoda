We can now deploy the Workspace building block.

## Kubernetes Secrets

Kubernetes secrets are used to share the credentials that the Workspace services rely upon.

```bash
bash apply-secrets.sh
```{{exec}}

## Workspace Dependencies

The workspace dependencies include CSI-RClone for storage mounting and the Educates framework for workspace environments.

```bash
# Deploy CSI-RClone
helm upgrade -i workspace-dependencies-csi-rclone \
  oci://ghcr.io/eoepca/workspace/workspace-dependencies-csi-rclone \
  --version 2.0.0-rc.12 \
  --namespace workspace

# Deploy Educates
helm upgrade -i workspace-dependencies-educates \
  oci://ghcr.io/eoepca/workspace/workspace-dependencies-educates \
  --version 2.0.0-rc.12 \
  --namespace workspace \
  --values workspace-dependencies/educates-values.yaml
```{{exec}}

## Workspace API

The Workspace API provides a REST interface for administration of workspaces.

```bash
helm repo add eoepca https://eoepca.github.io/helm-charts
helm repo update eoepca
helm upgrade -i workspace-api eoepca/rm-workspace-api \
  --version 2.0.0-rc.7 \
  --namespace workspace \
  --values workspace-api/generated-values.yaml \
  --set image.tag=2.0.0-rc.8
```{{exec}}

## Workspace Pipeline

The Workspace Pipeline manages the templating and provisioning of resources within newly created workspaces.

```bash
helm upgrade -i workspace-pipeline \
  oci://ghcr.io/eoepca/workspace/workspace-pipeline \
  --version 2.0.0-rc.12 \
  --namespace workspace \
  --values workspace-pipeline/generated-values.yaml
```{{exec}}

## DataLab Session Cleaner

This deploys a CronJob that automatically cleans up inactive DataLab sessions - removing all sessions except the default ones.

```bash
kubectl apply -f workspace-cleanup/datalab-cleaner.yaml
```{{exec}}

## Workspace Admin Dashboard

The Workspace BB solution is fully Kubernetes-native, making full use of custom CRDs via Crossplane. Thus the _Kubernetes Dashboard_ is relied upon for administration.

```bash
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update kubernetes-dashboard
helm upgrade -i workspace-admin kubernetes-dashboard/kubernetes-dashboard \
  --version 7.10.1 \
  --namespace workspace \
  --values workspace-admin/generated-values.yaml
```{{exec}}

The deployment does not establish any ingress for the Dashboard - but it can be accessed via port forwarding at http://localhost:8000.

```bash
kubectl -n workspace port-forward svc/workspace-admin-web 8000
```{{exec}}

## Crossplane Provider Configurations

The Workspace BB uses several Crossplane providers to manage resources - each of which requires a corresponding ProviderConfig to be deployed in the workspace namespace. The exception is the MinIO provider, which requires a cluster-wide ProviderConfig that was already deployed as part of the Crossplane prerequisite.
* **MinIO Provider**, for S3-compatible storage
* **Kubernetes Provider**, for managing Kubernetes resources
* **Keycloak Provider**, for IAM integration
* **Helm Provider**, for deploying Helm charts within workspaces

```bash
cat <<EOF | kubectl apply -f -
apiVersion: kubernetes.m.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: provider-kubernetes
  namespace: workspace
spec:
  credentials:
    source: InjectedIdentity
---
apiVersion: keycloak.m.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: provider-keycloak
  namespace: workspace
spec:
  credentialsSecretRef:
    name: workspace-pipeline-client
    key: credentials
---
apiVersion: helm.m.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: provider-helm
  namespace: workspace  
spec:
  credentials:
    source: InjectedIdentity
EOF
```{{exec}}

## Keycloak Clients for Workspace

We create two Keycloak clients for use by the Workspace BB:
* `workspace-api`<br>
  _Used for OIDC policy enforcement of the Workspace API endpoint_
* `workspace-pipeline`<br>
  _Used by the Workspace to perform user management functions for protection of newly created workspaces_

> We use CRDs to create and configure these clients - via the Crossplane Keycloak Provider that has already been established in the `iam-management` namespace.

## Client `workspace-pipeline`

**_Create the client_**

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
# Secret providing client_secret for Client creation.
apiVersion: v1
kind: Secret
metadata:
  name: workspace-pipeline-keycloak-client
  namespace: iam-management
stringData:
  client_secret: "${WORKSPACE_PIPELINE_CLIENT_SECRET}"
---
# Create the Keycloak Client
apiVersion: openidclient.keycloak.m.crossplane.io/v1alpha1
kind: Client
metadata:
  name: "${WORKSPACE_PIPELINE_CLIENT_ID}"
  namespace: iam-management
spec:
  forProvider:
    realmId: ${REALM}
    clientId: ${WORKSPACE_PIPELINE_CLIENT_ID}
    name: Workspace Pipelines
    description: Workspace Pipelines Admin
    enabled: true
    accessType: CONFIDENTIAL
    rootUrl: ${HTTP_SCHEME}://workspace-pipeline.${INGRESS_HOST}
    baseUrl: ${HTTP_SCHEME}://workspace-pipeline.${INGRESS_HOST}
    adminUrl: ${HTTP_SCHEME}://workspace-pipeline.${INGRESS_HOST}
    serviceAccountsEnabled: true
    directAccessGrantsEnabled: true
    standardFlowEnabled: true
    oauth2DeviceAuthorizationGrantEnabled: true
    useRefreshTokens: true
    authorization:
      - allowRemoteResourceManagement: false
        decisionStrategy: UNANIMOUS
        keepDefaults: true
        policyEnforcementMode: ENFORCING
    validRedirectUris:
      - "/*"
    webOrigins:
      - "/*"
    clientSecretSecretRef:
      name: workspace-pipeline-keycloak-client
      key: client_secret
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
```{{exec}}

**_Configure the Workspace-dedicated Keycloak Provider with the client credentials_**

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
# Secret providing credentials for Crossplane Keycloak Provider.
apiVersion: v1
kind: Secret
metadata:
  name: workspace-pipeline-client
  namespace: workspace
stringData:
  credentials: |
    {
      "client_id": "${WORKSPACE_PIPELINE_CLIENT_ID}",
      "client_secret": "${WORKSPACE_PIPELINE_CLIENT_SECRET}",
      "url": "http://iam-keycloak.iam",
      "base_path": "",
      "realm": "${REALM}"
    }
EOF
```{{exec}}

**_Add the Realm Management roles to the client_**

```bash
source ~/.eoepca/state
for role in manage-users manage-authorization manage-clients create-client; do
cat <<EOF | kubectl apply -f -
apiVersion: openidclient.keycloak.m.crossplane.io/v1alpha1
kind: ClientServiceAccountRole
metadata:
  name: workspace-pipeline-client-${role}
  namespace: iam-management
spec:
  forProvider:
    realmId: ${REALM}
    serviceAccountUserClientIdRef:
      name: ${WORKSPACE_PIPELINE_CLIENT_ID}
      namespace: iam-management
    clientIdRef:
      name: realm-management
      namespace: iam-management
    role: ${role}
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
done
```{{exec}}

## Client `workspace-api`

For the `workspace-api` client, we use the 'external tutorial' hostname for the Workspace API client - as this is what will be used via the tutorial UI to access the service.

```bash
source ~/.eoepca/state
WORKSPACE_EXT_API_HOST="$(
  sed "s#http://PORT#$(awk -v host="$INGRESS_HOST" '$0 ~ ("workspace-api." host) {print $1}' /tmp/assets/killercodaproxy)#" \
    /etc/killercoda/host
)"
echo "Workspace API external host: ${WORKSPACE_EXT_API_HOST}"
```{{exec}}

**_Create the client_**

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${WORKSPACE_API_CLIENT_ID}-keycloak-client
  namespace: iam-management
stringData:
  client_secret: ${WORKSPACE_API_CLIENT_SECRET}
---
apiVersion: openidclient.keycloak.m.crossplane.io/v1alpha1
kind: Client
metadata:
  name: ${WORKSPACE_API_CLIENT_ID}
  namespace: iam-management
spec:
  forProvider:
    realmId: ${REALM}
    clientId: ${WORKSPACE_API_CLIENT_ID}
    name: Workspace API
    description: Workspace API OIDC
    enabled: true
    accessType: CONFIDENTIAL
    rootUrl: ${HTTP_SCHEME}://${WORKSPACE_EXT_API_HOST}
    baseUrl: ${HTTP_SCHEME}://${WORKSPACE_EXT_API_HOST}
    adminUrl: ${HTTP_SCHEME}://${WORKSPACE_EXT_API_HOST}
    serviceAccountsEnabled: true
    directAccessGrantsEnabled: true
    standardFlowEnabled: true
    oauth2DeviceAuthorizationGrantEnabled: true
    useRefreshTokens: true
    authorization:
      - allowRemoteResourceManagement: false
        decisionStrategy: UNANIMOUS
        keepDefaults: true
        policyEnforcementMode: ENFORCING
    validRedirectUris:
      - "/*"
      - "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/*"
    webOrigins:
      - "/*"
    clientSecretSecretRef:
      name: ${WORKSPACE_API_CLIENT_ID}-keycloak-client
      key: client_secret
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
```{{exec}}

**_Workspace API Ingress_**

```bash
kubectl apply -f workspace-api/generated-ingress.yaml
```{{exec}}

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
    name: provider-keycloak
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
    name: provider-keycloak
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
