## Keycloak Admin UI

The Keycloak web UI has been made accessible through [this URL]({{TRAFFIC_HOST1_90}}).

Login with the user `admin`{{}} and the password defined by the env var `KEYCLOAK_ADMIN_PASSWORD`{{}}.

```bash
cat ~/.eoepca/state | grep KEYCLOAK_ADMIN_PASSWORD
```{{exec}}

[Click here]({{TRAFFIC_HOST1_90}}) to open the Keycloak UI.

Select the `eoepca`{{}} realm.

Browse through the `Clients`{{}} and `Users`{{}} to see those previously created.
