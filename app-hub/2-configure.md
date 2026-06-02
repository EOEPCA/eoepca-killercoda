
## Configure the Application Hub

Run the configuration script to generate the necessary Helm values:

```bash
bash configure-app-hub.sh
```{{exec}}

When prompted, provide the following configuration values.

For the base domain name:
```
eoepca.local
```{{exec}}

For the storage class:
```
local-path
```{{exec}}

We dont need to enable TLS for local development, so for the TLS option, enter:
```
no
```{{exec}}

For the node selector key:
```
kubernetes.io/os
```{{exec}}

For the node selector value:
```
linux
```{{exec}}

For the OAuth client ID:
```
application-hub
```{{exec}}

The script will generate a client secret automatically. Make note of this value as you'll need it for the Keycloak client creation.

The configuration script generates two files:
- `generated-values.yaml` - Helm values for the Application Hub
- `generated-ingress.yaml` - Ingress configuration

> TODO: Remove this when fixed properly....
> Only run this if you are running from `lc.tutorials.eoepca.org`

```bash
source ~/.eoepca/state
sed -i "s#http://${KEYCLOAK_HOST}#https://${KEYCLOAK_HOST}#g" generated-values.yaml
```

You can inspect the generated values:

```bash
cat generated-values.yaml
```{{exec}}