
## Setting Up the Client and User

With Keycloak and OPA running, we need to do some one-off setup in Keycloak: create a realm for EOEPCA, add a test user, and set up a client for OPA and Identity API. There are utility scripts to help with this.

### 1. Create an EOEPCA User

```bash
bash ../utils/create-user.sh
```{{exec}}

The script will ask for (hit enter to take the proposed value):

- **Keycloak Admin Username/Password:** Hit enter
- **Keycloak Base URL:** `y` to update the value to: `auth.eoepca.local:31443` # we need to set the NodePort in this scenario.
- **Realm:** Use `eoepca` (as set up earlier).
- **New User Username:** `eoepcauser` (or any username you prefer).
- **New User Password:** `eoepcapassword` (or any password you prefer).

```
bash ../utils/create-user.sh <<EOF


y
auth.eoepca.local:31443

eoepcauser
eoepcapassword
EOF
```

### 2. Create the OPA Client in Keycloak

Next, we need to create an OIDC client in Keycloak for OPA.

Run the script:

```bash
bash ../utils/create-client.sh
```

- **Keycloak Admin login:** Hit enter
- **Ingress Host:** Hit enter
- **Keycloak Base Domain:** This should be set to `auth.eoepca.local:31443` (the NodePort for Keycloak).
- **Realm:** `eoepca`.
- **Confidential Client?:** `true` (this will be a confidential client with a secret).
- **Client ID:** `opa` (use "opa" as the client ID).
- **Client Name/Description:** For example, `OPA Client` or "Open Policy Agent client".
- **Client Secret:** The OPA client secret from `~/.eoepca/state` under `OPA_CLIENT_SECRET`. Copy and paste it when asked.
- **Subdomain:** `opa` (this sets the redirect URI/host as `opa.${INGRESS_HOST}`).
- **Additional Hosts:** Leave blank.

```bash
source ~/.eoepca/state
bash ../utils/create-client.sh <<EOF
n
n
n
n
n
true
opa
OPA Client
Open Policy Agent client
${OPA_CLIENT_SECRET}
opa


EOF
```

### 3. Register the Identity API Client in Keycloak

Next, we need to create an OIDC client in Keycloak for the Identity API.

Run the script:

```bash
bash ../utils/create-client.sh
```

- **Keycloak Admin login:** Hit enter (it will use the value from the state file).
- **Ingress Host:** Hit enter (it will use the value from the state file).
- **Keycloak Base Domain:** This should be set to `auth.eoepca.local:31443`
- **Realm:** `eoepca`.
- **Confidential Client?:** `true` 
- **Client ID:** `identity-api` (use "identity-api" as the client ID).
- **Client Name/Description:** For example, `Identity API Client` or "Identity API client".
- **Client Secret:** The Identity API client secret from `~/.eoepca/state` under `IDENTITY_API_CLIENT_SECRET`. Copy and paste it when asked.
- **Subdomain:** `identity-api` (this sets the redirect URI/host as `identity-api.${INGRESS_HOST}`).
- **Additional Hosts:** Leave blank.

```bash
source ~/.eoepca/state
bash ../utils/create-client.sh <<EOF
n
n
n
n
n
true
identity-api
Identity API Client
Identity API client
${IDENTITY_API_CLIENT_SECRET}
identity-api


EOF
```