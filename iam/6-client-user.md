
## Setting Up the Client and User

With Keycloak and OPA running, we need to do some one-off setup in Keycloak: create a realm for EOEPCA, add a test user, and set up a client for OPA. There are utility scripts to help with this.

### 1. Create the EOEPCA Realm and a User

Keycloak starts with a **eoepca** realm for admin tasks. For EOEPCA, it's best to use a separate realm. The `configure-iam.sh` script has already saved your chosen realm name (usually "eoepca") in the state. Now we'll create that realm and a user.

Run the **create-user** script:

```bash
bash ../utils/create-client.sh
```

The script will ask for:

- **Keycloak Admin Username/Password:** Use the admin details from `~/.eoepca/state` (username is usually `admin`, password is in `KEYCLOAK_ADMIN_PASSWORD`).
- **Keycloak Base URL:** For example, `auth.${INGRESS_HOST}` (like `auth.example.com`).
- **Realm:** Use `eoepca` (as set up earlier).
- **New User Username:** For example, `eoepcauser` (this will be your test user).
- **New User Password:** Choose a password (e.g. `eoepcapassword`). You'll use this for login tests.

The script will create the `eoepca` realm (if it doesn't already exist) and add the new user with the details you provide. It may also assign a default role or group, depending on the script.

### 2. Register the OPA Client in Keycloak

Next, we need to create an OIDC client in Keycloak for OPA. This lets OPA (and OPAL) authenticate with Keycloak for token checks or policy queries. The `create-client.sh` script does this using Keycloak's REST API.

Run the script:

```bash
bash create-client.sh
```

You'll be asked for:

- **Keycloak Admin login:** Username and password from the state file (same as above).
- **Keycloak Base Domain:** For example, `auth.${INGRESS_HOST}` (like `auth.example.com`).
- **Realm:** `eoepca`.
- **Confidential Client?:** Yes (this will be a confidential client with a secret).
- **Client ID:** `opa` (use "opa" as the client ID).
- **Client Name/Description:** For example, `OPA Client` or "Open Policy Agent client".
- **Client Secret:** The OPA client secret from `~/.eoepca/state` under `OPA_CLIENT_SECRET`. Copy and paste it when asked.
- **Subdomain:** `opa` (this sets the redirect URI/host as `opa.${INGRESS_HOST}`).
- **Additional Hosts:** Leave blank unless you have more hostnames.

The script will create the client in Keycloak. If it works, you'll see a JSON summary of the new client. Now Keycloak trusts a client with ID "opa" and the secret you gave, and will issue tokens
