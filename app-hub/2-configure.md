
## Configure the Application Hub

Run the configuration script to generate the necessary Helm values:

```bash
bash configure-app-hub.sh
```{{exec}}

When prompted, provide the following configuration values. The shared domain/storage/TLS
questions were already answered while checking prerequisites in the previous step, so this
script only asks about the Application Hub itself.

For the node selector key:
```
kubernetes.io/os
```{{exec}}

For the node selector value:
```
linux
```{{exec}}

For the public Application Hub host:
```
app-hub.eoepca.local
```{{exec}}

For the OAuth client ID:
```
application-hub
```{{exec}}

The script generates the client secret itself and renders it into the Keycloak client manifest, along with three other files:

- `generated-values.yaml` - Helm values for the Application Hub
- `generated-ingress.yaml` - Ingress configuration
- `generated-iam.yaml` - Keycloak client
- `generated-demo-user.yaml` - demo admin user `eric`

You can inspect the generated values:

```bash
cat generated-values.yaml
```{{exec}}