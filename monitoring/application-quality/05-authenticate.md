
Managing pipelines requires an authenticated user. The portal signs users in through Keycloak,
while scripts and CI jobs call the API with a token.

### Log in to the web portal

1. Open the Application Quality portal: **[Open Portal]({{TRAFFIC_HOST1_81}})**
2. Click **Login** in the navigation bar. You are redirected to the EOEPCA Keycloak realm.
3. Enter the credentials of the tutorial test user:
   - Username: `eoepcauser`{{}}
   - Password: `eoepcapassword`{{}}
4. Keycloak redirects you back to the portal, which now shows your username in the top navigation.

You can now browse **Pipelines**, **Monitoring** and **Reports** in the portal.

### Get an API token for this terminal

The portal uses a browser session, which we cannot share with the terminal. For command line access
the API issues a token to a local account - the admin account created during configuration:

```bash
export AQ_TOKEN=$(
  curl -sS -X POST "$AQ_URL/api/token/" \
    -H "Content-Type: application/json" \
    -d "{\"username\": \"$APP_QUALITY_ADMIN_USER\", \"password\": \"$APP_QUALITY_ADMIN_PASSWORD\"}" \
  | jq -r '.access'
)
curl -sS -H "Authorization: Bearer $AQ_TOKEN" "$AQ_URL/api/pipelines/" | jq
```{{exec}}

The response lists the pipelines that ship with the building block. Each one is a sequence of the
analysis tools we saw in the previous step.

> The token is valid for five minutes. If a later command returns `Token is expired`{{}}, run the
> block above again.

### View the terminal's runs in the portal

The terminal uses the local admin account. The Keycloak test user has a separate account and cannot
see runs or private pipelines created by that admin.

Before following the next steps in the portal, log out and open
[the admin login]({{TRAFFIC_HOST1_81}}/admin/login/). Use the local credentials:

```bash
echo "$APP_QUALITY_ADMIN_USER"
echo "$APP_QUALITY_ADMIN_PASSWORD"
```{{exec}}

After signing in, return to [the portal]({{TRAFFIC_HOST1_81}}/). **Monitoring**, **Reports** and
**Pipelines** now show the resources you create from this terminal.
