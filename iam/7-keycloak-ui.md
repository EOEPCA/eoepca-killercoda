## Keycloak Admin UI

**Port forward to the Keycloak service**

In order to access the Keycloak web UI, due to the limitations of this tutorial environment, it is necessary to port-forward directly to the Keycloak service.

Open another terminal tab to intitiate the port forwarding.

First we need the `socat`{{}} command:

```bash
apt update && apt install socat
```{{exec}}

Now we can initiate the port forwarding:

```bash
kubectl -n iam port-forward svc/iam-keycloak 8080:80 &
socat TCP4-LISTEN:8888,fork TCP4:127.0.0.1:8080 &
```{{exec}}

**Switch back to the previous terminal tab, in the `deployment-guide/scripts/iam`{{}} directory.**

**Open the Keycloak Web UI**

Login with the user `admin` and the password defined by the env var `KEYCLOAK_ADMIN_PASSWORD`.

```bash
cat ~/.eoepca/state | grep KEYCLOAK_ADMIN_PASSWORD
```{{exec}}

[Click here]({{TRAFFIC_HOST1_8888}}) to open the Keycloak UI.

Select the `eoepca` realm.

Browse through the `Clients` and `Users` to see those previously created.
