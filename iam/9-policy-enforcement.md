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

For convenience we have a template into which we can inject our values:

```bash
source ~/.eoepca/state
gomplate -f /tmp/assets/apisixroute-nginx.yaml | kubectl apply -f -
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

Open [the 'open' endpoint]({{TRAFFIC_HOST1_92}}) in your browser.

The typical nginx `Welcome`{{}} page html is returned.

### 4. Check the protection (Unauthorized)

We attempt to access the protected endpoint with a simple unauthenticated request (i.e. no access token).

Open [the 'protected' endpoint]({{TRAFFIC_HOST1_93}}) in your browser.

The browser should be redirected to Keycloak for login.<br>
The policy enforcement has recognised the absence of the access token, and has triggered an OIDC login flow via Keycloak.

### 5. Check the protection (Allowed)

For allowed access we need to authenticate as a user that is identified as `privileged`{{}} in accordance with the policy - such as our `eoepcauser`{{}} test user.

At the Keycloak login prompt, enter the credentials for the `eoepcauser` - password `eoepcapassword`.

Following successful login, the browser should be redirected back to the [protected service endpoint]({{TRAFFIC_HOST1_93}}) - showing the nginx `Welcome`{{}} page.

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

**Ensure we are logged out from `eoepcauser`**

Navigate to the [Keycloak user dashboard]({{TRAFFIC_HOST1_90}}/realms/eoepca/account) and select to logout.

**Attempt access for an unprivileged user**

Repeat the access attempt to [the 'protected' endpoint]({{TRAFFIC_HOST1_93}}) in your browser.

As before, the browser should be redirected to Keycloak for login.

At the Keycloak login prompt, enter the credentials for the `eric` - password `eoepcapassword`.

Following successful login, the browser should be redirected back to the [protected service endpoint]({{TRAFFIC_HOST1_93}}) - but access should be **Forbidden**.

The policy enforcement has recognised the presence of the access token, from which it is able to assert that the referenced user (`eric`{{}}) is not authorized to access the requested resource.
