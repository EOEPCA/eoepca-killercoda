
## Create the Keycloak Client

The Application Hub requires an OIDC client in Keycloak for authentication. We'll create this using the Crossplane Keycloak provider.

Wait for the Crossplane provider to be ready:

```bash
kubectl wait --for=condition=Healthy provider/provider-keycloak -n crossplane-system --timeout=2m 2>/dev/null || echo "Waiting for provider..."
```{{exec}}

Now create the Keycloak client for the Application Hub:

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${APPHUB_CLIENT_ID:-application-hub}-keycloak-client
  namespace: iam-management
stringData:
  client_secret: ${APPHUB_CLIENT_SECRET}
---
apiVersion: openidclient.keycloak.m.crossplane.io/v1alpha1
kind: Client
metadata:
  name: ${APPHUB_CLIENT_ID:-application-hub}
  namespace: iam-management
spec:
  forProvider:
    realmId: ${REALM:-eoepca}
    clientId: ${APPHUB_CLIENT_ID:-application-hub}
    name: Application Hub
    description: Application Hub OIDC
    enabled: true
    accessType: CONFIDENTIAL
    rootUrl: ${HTTP_SCHEME}://app-hub.${INGRESS_HOST}
    baseUrl: ${HTTP_SCHEME}://app-hub.${INGRESS_HOST}
    adminUrl: ${HTTP_SCHEME}://app-hub.${INGRESS_HOST}
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
      name: ${APPHUB_CLIENT_ID:-application-hub}-keycloak-client
      key: client_secret
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
```{{exec}}
