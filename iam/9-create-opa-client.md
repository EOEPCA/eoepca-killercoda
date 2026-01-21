
A Keycloak client is required for the ingress protection of the Open Policy Agent (OPA) service. The client can be created using the Crossplane Keycloak provider via the `Client`{{}} CRD.

### **Client Secret**

First we use a `Secret`{{}} to securely inject the client secret.

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${OPA_CLIENT_ID}-keycloak-client
  namespace: iam-management
stringData:
  client_secret: ${OPA_CLIENT_SECRET}
EOF
```{{exec}}

### **Client Creation**

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: openidclient.keycloak.m.crossplane.io/v1alpha1
kind: Client
metadata:
  name: ${OPA_CLIENT_ID}
  namespace: iam-management
spec:
  forProvider:
    realmId: ${REALM}
    clientId: ${OPA_CLIENT_ID}
    name: Open Policy Agent
    description: Open Policy Agent OIDC
    enabled: true
    accessType: CONFIDENTIAL
    rootUrl: ${HTTP_SCHEME}://opa.${INGRESS_HOST}
    baseUrl: ${HTTP_SCHEME}://opa.${INGRESS_HOST}
    adminUrl: ${HTTP_SCHEME}://opa.${INGRESS_HOST}
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
      name: ${OPA_CLIENT_ID}-keycloak-client
      key: client_secret
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
```{{exec}}

### **Verify Clients**

Login to the [Keycloak Admin Console]({{TRAFFIC_HOST1_90}}/admin/master/console/#/eoepca/clients) to check the client has been created by the Keycloak Provider from the _Custom Resources_ - using the `admin`{{}} credentials defined in the `~/.eoepca/state`{{}} file.

```bash
grep KEYCLOAK_ADMIN_ ~/.eoepca/state
```{{exec}}

> Navigate to the `eoepca`{{}} realm, then to the `Clients`{{}} section to see the `opa`{{}} client - and other clients created previously, such as that for `iam-management`{{}}.
