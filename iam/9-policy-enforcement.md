## Policy Enforcement

Now that we have validated the Keycloak and Open Policy Agent (OPA) services, we can apply an ingress that protects access to a given endpoint by applying an enforcement policy.

We will use the policy here - https://github.com/EOEPCA/iam-policies/blob/main/policies/example/tutorial/protected.rego - which expects a valid JWT in the request `Authorization`{{}} header, and expects the user identified in the JWT to match one of the configured `privileged_users`{{}} - ref. https://github.com/EOEPCA/iam-policies/blob/main/policies/example/data.json.

> NOTE that use of the `data.json`{{}} file to specify privileged users is a simple approach. In production, you might instead use the policy to, for example, check Keycloak group memberships defined in the JWT claims.

### 1. Service to be Protected

We will create a dummy service to which the protection can be applied and demonstrated. For this we will use an nginx instance.

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80
```{{exec}}

### 2. Apply Protection

To establish the external ingress to the service we use an `ApisixRoute`{{}} resource, which is used to configure the Apisix reverse proxy.

For convenience we create first a template via:

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
        # Authenticate - expect JWT in 'Authorization: Bearer' header
        - name: openid-connect
          enable: true
          config:
            discovery: "{{ getenv "OIDC_ISSUER_URL" }}/.well-known/openid-configuration"
            realm: {{ getenv "OPA_CLIENT_SECRET" }}
            client_id: {{ getenv "OPA_CLIENT_ID" }}
            client_secret: {{ getenv "OPA_CLIENT_SECRET" }}
            use_jwks: true
            bearer_only: false
            set_access_token_header: true
            access_token_in_authorization_header: true
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

The protected `nginx`{{}} route uses 2 plugins:

* `openid-connect`{{}} - Authnentication - ensures the user is authenticated via bearer JWT token, and will trigger an OIDC auth flow if required
* `opa`{{}} - Authorization - enforces the [`example/tutorial/protected`{{}}](https://github.com/EOEPCA/iam-policies/blob/main/policies/example/tutorial/protected.rego) policy

### 3. Check the route

First we can use the open endpoint to check the service is running.

```bash
curl http://nginx-open.eoepca.local
```{{exec}}

The typical nginx landing page html is returned.

### 4. Check the protection (Unauthorized)

First we attempt to access the protected endpoint with a simple unauthenticated request (i.e. no access token).

```bash
curl http://nginx.eoepca.local -v
```{{exec}}

This returns a `302` response with a `Location`{{}} response header that points to Keycloak's `/auth`{{}} endpoint.<br>
The policy enforcement has recognised the absence of the access token, and has triggered an OIDC login flow via Keycloak.

### 5. Check the protection (Allowed)

For allowed access we need to authenticate as a user that is identified as `privileged`{{}} in accordance with the policy - such as our `eoepcauser`{{}} test user.

**Authenticate to obtain an access token**

> For convenience we are reusing the existing `opa`{{}} Keycloak client. Ordinarily a dedicated Keycloak client would be created to represent the endpoints of each specific application

```bash
source ~/.eoepca/state
# Authenticate as test user `eoepcauser`
ACCESS_TOKEN=$( \
  curl --silent --show-error \
    -X POST \
    -d "username=eoepcauser" \
    --data-urlencode "password=eoepcapassword" \
    -d "grant_type=password" \
    -d "client_id=opa" \
    -d "client_secret=${OPA_CLIENT_SECRET}" \
    "http://auth.eoepca.local/realms/eoepca/protocol/openid-connect/token" | jq -r '.access_token' \
)
echo "ACCESS TOKEN: ${ACCESS_TOKEN}"
```{{exec}}

**Use the access token for the protected service**

```bash
curl "http://nginx.eoepca.local" -H "Authorization: Bearer ${ACCESS_TOKEN}"
```{{exec}}

The typical nginx landing page html is returned - indicating that the request was authorized.

### 6. Check the protection (Forbidden)

As a final check we will make a request with a valid access token, but for the user `eric`{{}} that is not on the list of privileged users.

**Create User `eric`{{}}**

Create the user `eric`{{}} using the helper scripts, as before:

```bash
bash ../utils/create-user.sh
```{{exec}}

Use the following provided values:<br>
_Select the provided values to inject them into the terminal prompts_

> NOTE that some of the previosly answered questions are repeated - in which case the existing value can be accepted.

* `KEYCLOAK_ADMIN_USER`{{}} already set: `n`{{exec}}
* `KEYCLOAK_ADMIN_PASSWORD`{{}} already set: `n`{{exec}}
* `KEYCLOAK_HOST`{{}} already set: `n`{{exec}}
* `REALM`{{}} already set: `n`{{exec}}
* Username: `eric`{{exec}}<br>
  Name of the new user to create
* Password: `eoepcapassword`{{exec}}<br>
  Password for the newly created user

**Obtain access token for (unprivileged) user `eric`{{}}**

```bash
source ~/.eoepca/state
# Authenticate as test user `eric`
ACCESS_TOKEN=$( \
  curl --silent --show-error \
    -X POST \
    -d "username=eric" \
    --data-urlencode "password=eoepcapassword" \
    -d "grant_type=password" \
    -d "client_id=opa" \
    -d "client_secret=${OPA_CLIENT_SECRET}" \
    "http://auth.eoepca.local/realms/eoepca/protocol/openid-connect/token" | jq -r '.access_token' \
)
echo "ACCESS TOKEN: ${ACCESS_TOKEN}"
```{{exec}}

**Use the access token for the protected service**

```bash
curl "http://nginx.eoepca.local" -H "Authorization: Bearer ${ACCESS_TOKEN}"
```{{exec}}

This returns a `403`{{}} response which indicates that the request is forbidden.
The policy enforcement has recognised the presence of the access token, from which it is able to assert that the referenced user (`eric`{{}}) is not authorized to access the requested resource.
