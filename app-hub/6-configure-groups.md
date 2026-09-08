
## Configure Groups in the Application Hub

The Application Hub filters the profiles it offers by the JupyterHub groups a user belongs to. Each profile in the Hub's configuration lists the groups allowed to use it, so a user with no groups is offered nothing.

Open the [Application Hub]({{TRAFFIC_HOST1_83}}) and log in as `eric`{{}} with the password `eoepcapassword`{{}}. Keycloak handles the login and returns you to the Hub.

Go to the [Admin Panel]({{TRAFFIC_HOST1_83}}/hub/admin#/) and select [**Manage Groups**]({{TRAFFIC_HOST1_83}}/hub/admin#/groups).

Create two groups with this exact naming:

- `group-1`
- `group-3`

Then assign the `eric` user to both groups and click **Apply**.

`group-1` carries the Streamlit dashboard used in the next step, `group-3` the JupyterLab environment used after it. The default configuration also defines `group-2`, whose profiles are not used in this tutorial.
