
Now that we have validated the Keycloak and Open Policy Agent (OPA) services, we can apply an ingress that protects access to a given endpoint by applying an enforcement policy.

We will use the policy here - https://github.com/EOEPCA/iam-policies/blob/main/policies/example/tutorial/protected.rego - which expects a valid JWT in the request `Authorization`{{}} header, and expects the user identified in the JWT to match one of the configured `privileged_users`{{}} - ref. https://github.com/EOEPCA/iam-policies/blob/main/policies/example/data.json.

> NOTE that use of the `data.json`{{}} file to specify privileged users is a simple approach. In production, you might instead use the policy to, for example, check Keycloak group memberships defined in the JWT claims.

## **1. Service to be Protected**

We will create a dummy service to which the protection can be applied and demonstrated. For this we will use an nginx instance.

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80
```{{exec}}

## **2. Create a Keycloak Client for the Dummy Service**

A Keycloak client is required for the ingress protection of the dummy nginx service - to paricipate in OIDC flows for delegated access.

In order for the OIDC redirect URIs to work correctly, we need to create a dedicated client for the nginx service - which must use the external URLs that are exposed by this tutorial environment:

```bash
export DUMMY_HOST="$(port="$(grep nginx.eoepca.local /tmp/assets/killercodaproxy | awk '{print $1}')" ; sed "s#http://PORT#$port#" /etc/killercoda/host )"
echo "External Dummy Service host: ${DUMMY_HOST}"
```{{exec}}

Create the client:

```bash
source ~/.eoepca/state
export DUMMY_CLIENT_ID="dummy"
export DUMMY_CLIENT_SECRET="$(openssl rand -hex 16)"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: dummy-keycloak-client
  namespace: iam-management
stringData:
  client_secret: ${DUMMY_CLIENT_SECRET}
---
apiVersion: openidclient.keycloak.m.crossplane.io/v1alpha1
kind: Client
metadata:
  name: ${DUMMY_CLIENT_ID}
  namespace: iam-management
spec:
  forProvider:
    realmId: ${REALM}
    clientId: ${DUMMY_CLIENT_ID}
    name: Dummy Service
    description: Dummy Service OIDC
    enabled: true
    accessType: CONFIDENTIAL
    rootUrl: ${HTTP_SCHEME}://${DUMMY_HOST}
    baseUrl: ${HTTP_SCHEME}://${DUMMY_HOST}
    adminUrl: ${HTTP_SCHEME}://${DUMMY_HOST}
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
      name: ${DUMMY_CLIENT_ID}-keycloak-client
      key: client_secret
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
```{{exec}}

## **3. Apply Protection**

To establish the external ingress to the service we use an `ApisixRoute`{{}} resource, which is used to configure the Apisix reverse proxy.

> For convenience we define the `ApisixRoute`{{}} resource in a template file - which allows us to inject the required values using `gomplate`{{}}.

```
cat <<EOF > ~/apisixroute-nginx.yaml
apiVersion: apisix.apache.org/v2
kind: ApisixRoute
metadata:
  name: nginx
spec:
  http:
    # Open access
    - name: nginx-open
      match:
        hosts:
          - nginx-open.{{ getenv "INGRESS_HOST" }}
        paths:
          - /*
      backends:
        - serviceName: nginx
          servicePort: 80
    # Protected access
    - name: nginx
      match:
        hosts:
          - nginx.{{ getenv "INGRESS_HOST" }}
        paths:
          - /*
      backends:
        - serviceName: nginx
          servicePort: 80
      plugins:
        # Disable caching for protected content
        - name: response-rewrite
          enable: true
          config:
            headers:
              Cache-Control: "no-store"
              Pragma: "no-cache"
        # Authenticate - expect JWT in 'Authorization: Bearer' header
        - name: openid-connect
          enable: true
          config:
            discovery: "{{ getenv "OIDC_ISSUER_URL" }}/.well-known/openid-configuration"
            realm: {{ getenv "REALM" }}
            client_id: {{ getenv "DUMMY_CLIENT_ID" }}
            client_secret: {{ getenv "DUMMY_CLIENT_SECRET" }}
            use_jwks: true
            bearer_only: false
            set_access_token_header: true
            access_token_in_authorization_header: true
            logout_path: /logout
        # Authorization - required for access to API
        - name: opa
          enable: true
          config:
            host: http://iam-opal-client.iam:8181
            policy: example/tutorial/protected
EOF
```{{exec}}

which we can then use to inject our values:

```bash
source ~/.eoepca/state
gomplate -f ~/apisixroute-nginx.yaml | kubectl apply -f -
```{{exec}}

Inspect the route that has been applied:

```bash
kubectl get -oyaml apisixroute/nginx
```{{exec}}

The `ApisixRoute`{{}} route includes two routes:

* `nginx-open`{{}} - open access
* `nginx`{{}} - protected access

The protected `nginx`{{}} route uses 3 plugins:

* `openid-connect`{{}} - Authnentication - ensures the user is authenticated via bearer JWT token, and will trigger an OIDC auth flow if required
* `opa`{{}} - Authorization - enforces the [`example/tutorial/protected`{{}}](https://github.com/EOEPCA/iam-policies/blob/main/policies/example/tutorial/protected.rego) policy
* `response-rewrite`{{}} - Disables caching for protected content

## **4. Check the route**

First we can use the open endpoint to check the service is running.

```bash
curl http://nginx-open.eoepca.local
```{{exec}}

The typical nginx landing page html is returned.

## **5. Check the protection (Unauthorized)**

First we attempt to access the protected endpoint with a simple unauthenticated request (i.e. no access token).

```bash
curl http://nginx.eoepca.local -v
```{{exec}}

This returns a `302`{{}} response with a `Location`{{}} response header that points to Keycloak's `/auth`{{}} endpoint.<br>
The policy enforcement has recognised the absence of the access token, and has triggered an OIDC login flow via Keycloak.

## **6. Check the protection (Allowed)**

For allowed access we need to authenticate as a user that is identified as `privileged`{{}} in accordance with the policy - such as our `eoepcauser`{{}} test user.

**Authenticate to obtain an access token**

```bash
source ~/.eoepca/state
# Authenticate as test user `eoepcauser`{{}}
ACCESS_TOKEN=$( \
  curl --silent --show-error \
    -X POST \
    -d "username=eoepcauser" \
    --data-urlencode "password=eoepcapassword" \
    -d "grant_type=password" \
    -d "client_id=dummy" \
    -d "client_secret=${DUMMY_CLIENT_SECRET}" \
    "http://auth.eoepca.local/realms/eoepca/protocol/openid-connect/token" | jq -r '.access_token' \
)
echo "ACCESS TOKEN: ${ACCESS_TOKEN:0:20}..."
```{{exec}}

**Use the access token for the protected service**

```bash
curl "http://nginx.eoepca.local" -H "Authorization: Bearer ${ACCESS_TOKEN}"
```{{exec}}

The typical nginx landing page html is returned - indicating that the request was authorized.

## **7. Check the protection (Forbidden)**

As a final check we will make a request with a valid access token, but for the user `eoepcaadmin`{{}} that is not on the list of privileged users.

**Obtain access token for (unprivileged - according to policy) user `eoepcaadmin`{{}}**

```bash
source ~/.eoepca/state
ACCESS_TOKEN=$( \
  curl --silent --show-error \
    -X POST \
    -d "username=eoepcaadmin" \
    --data-urlencode "password=eoepcapassword" \
    -d "grant_type=password" \
    -d "client_id=dummy" \
    -d "client_secret=${DUMMY_CLIENT_SECRET}" \
    "http://auth.eoepca.local/realms/eoepca/protocol/openid-connect/token" | jq -r '.access_token' \
)
echo "ACCESS TOKEN: ${ACCESS_TOKEN:0:20}..."
```{{exec}}

**Use the access token for the protected service**

```bash
curl "http://nginx.eoepca.local" -H "Authorization: Bearer ${ACCESS_TOKEN}"
```{{exec}}

This returns a `403`{{}} response which indicates that the request is forbidden.
The policy enforcement has recognised the presence of the access token, from which it is able to assert that the referenced user (`eric`{{}}) is not authorized to access the requested resource.
