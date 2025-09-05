
## Setting Up the Client and User

We can use the Keycloak API to perform some post-deploy steps:
* add a test user
* set up an OIDC client for OPA

There are utility scripts to help with this.

### 1. Create an EOEPCA User

The helper script `create-user.sh`{{}} uses the Keycloak API to create a new user.

We will create the `eoepcauser`{{}} test user.

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
* Username: `eoepcauser`{{exec}}<br>
  Name of the new user to create
* Password: `eoepcapassword`{{exec}}<br>
  Password for the newly created user

### 2. Create the OPA Client in Keycloak

Next, we need to create an OIDC client in Keycloak for OPA.

Before running the script we will need the client secret that was previously generated:

```bash
cat ~/.eoepca/state | grep OPA_CLIENT_SECRET
```{{exec}}

The value of this secret will be used below.

Run the script:

```bash
bash ../utils/create-client.sh
```{{exec}}

Use the following provided values:<br>
_Select the provided values to inject them into the terminal prompts_

> NOTE that some of the previosly answered questions are repeated - in which case the existing value can be accepted.

* `KEYCLOAK_ADMIN_USER`{{}} already set: `n`{{exec}}
* `KEYCLOAK_ADMIN_PASSWORD`{{}} already set: `n`{{exec}}
* `INGRESS_HOST`{{}} already set: `n`{{exec}}
* `KEYCLOAK_HOST`{{}} already set: `n`{{exec}}
* `REALM`{{}} already set: `n`{{exec}}
* Confidential client?: `true`{{exec}}<br>
  A confidential client is able to maintain its client secret securely (e.g. a backend service)
* Client ID: `opa`{{exec}}<br>
  The ID of the OIDC client to be used by the OPA service
* Client Name: `OPA Client`{{exec}}<br>
  Display name for the client
* Client Description: `Open Policy Agent`{{exec}}<br>
  Description for the client
* Client Secret: <Paste value from above><br>
  The secret that, together with the Client ID, provides the client credentials
* Subdomain: `opa`{{exec}}<br>
  The main redirect URL for OIDC flows - within the `INGRESS_HOST`{{}} domain
* Additional Subdomains: <Leave blank><br>
  Additional redirect URLs for OIDC flows - within the `INGRESS_HOST`{{}} domain
* Additional Hosts: <Leave blank><br>
  Additional redirect URLs for OIDC flows - external (outside the `INGRESS_HOST`{{}} domain)

### 3. Register the Identity API Client in Keycloak

Similarly, we need to create an OIDC client in Keycloak for the Identity API.

Before running the script we will need the client secret that was previously generated:

```bash
cat ~/.eoepca/state | grep IDENTITY_API_CLIENT_SECRET
```{{exec}}

The value of this secret will be used below.

Run the script:

```bash
bash ../utils/create-client.sh
```{{exec}}

Use the following provided values:<br>
_Select the provided values to inject them into the terminal prompts_

> NOTE that some of the previosly answered questions are repeated - in which case the existing value can be accepted.

* `KEYCLOAK_ADMIN_USER`{{}} already set: `n`{{exec}}
* `KEYCLOAK_ADMIN_PASSWORD`{{}} already set: `n`{{exec}}
* `INGRESS_HOST`{{}} already set: `n`{{exec}}
* `KEYCLOAK_HOST`{{}} already set: `n`{{exec}}
* `REALM`{{}} already set: `n`{{exec}}
* Confidential client?: `true`{{exec}}<br>
  A confidential client is able to maintain its client secret securely (e.g. a backend service)
* Client ID: `identity-api`{{exec}}<br>
  The ID of the OIDC client to be used by the Identity API service
* Client Name: `Identity API`{{exec}}<br>
  Display name for the client
* Client Description: `Identity API`{{exec}}<br>
  Description for the client
* Client Secret: <Paste value from above><br>
  The secret that, together with the Client ID, provides the client credentials
* Subdomain: `identity-api`{{exec}}<br>
  The main redirect URL for OIDC flows - within the `INGRESS_HOST`{{}} domain
* Additional Subdomains: <Leave blank><br>
  Additional redirect URLs for OIDC flows - within the `INGRESS_HOST`{{}} domain
* Additional Hosts: <Leave blank><br>
  Additional redirect URLs for OIDC flows - external (outside the `INGRESS_HOST`{{}} domain)
