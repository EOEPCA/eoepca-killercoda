
Before deploying the Application Quality building block, we need to configure it.

This tutorial environment uses a proxy to route access to running services. We have to ensure that this proxied URL is well configured within the deployment - in particular for the Application Quality web UIs. Thus, we pre-configure here the environment variable `APP_QUALITY_PUBLIC_HOST` which is deduced from the running enviornment.

```bash
source ~/.eoepca/state
export APP_QUALITY_PUBLIC_HOST="$(
  sed "s#http://PORT#$(awk -v host="$INGRESS_HOST" '$0 ~ ("application-quality." host) {print $1}' /tmp/assets/killercodaproxy)#" \
    /etc/killercoda/host
)"
echo -e "\nPublic host for Application Quality: ${APP_QUALITY_PUBLIC_HOST}"
```{{exec}}

```
bash configure-application-quality.sh
```{{exec}}

When prompted, provide the following values.

Base domain name: (already set)
```
n
```{{exec}}

Storage class for persistent data:
```
local-path
```{{exec}}

No cert manager
```
no
```{{exec}}

Internal cluster issuer: (already set)
```
n
```{{exec}}

Enable OIDC authentication for Application Quality?
```
yes
```{{exec}}

Client ID for Application Quality:
```
application-quality
```{{exec}}

The script generates Helm values with OIDC configuration. 
Now we need to create the Keycloak client for Application Quality. This allows the web portal to authenticate users:

# Create the Keycloak client
```
source ~/.eoepca/state

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${APP_QUALITY_CLIENT_ID}-keycloak-client
  namespace: iam-management
stringData:
  client_secret: ${APP_QUALITY_CLIENT_SECRET}
---
apiVersion: openidclient.keycloak.m.crossplane.io/v1alpha1
kind: Client
metadata:
  name: ${APP_QUALITY_CLIENT_ID}
  namespace: iam-management
spec:
  forProvider:
    realmId: ${REALM:-eoepca}
    clientId: ${APP_QUALITY_CLIENT_ID}
    name: Application Quality
    description: Application Quality OIDC
    enabled: true
    accessType: CONFIDENTIAL
    rootUrl: ${HTTP_SCHEME:-http}://${APP_QUALITY_PUBLIC_HOST}
    baseUrl: ${HTTP_SCHEME:-http}://${APP_QUALITY_PUBLIC_HOST}
    adminUrl: ${HTTP_SCHEME:-http}://${APP_QUALITY_PUBLIC_HOST}
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
      name: ${APP_QUALITY_CLIENT_ID}-keycloak-client
      key: client_secret
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
```{{exec}}