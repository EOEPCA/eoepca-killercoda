
Before deploying the Application Quality building block, we need to configure it.

```
bash configure-application-quality.sh
```{{exec}}

When prompted, provide the following values.

Base domain name:
```
eoepca.local
```{{exec}}

Storage class for persistent data:
```
local-path
```{{exec}}


Internal cluster issuer:
```
eoepca-ca-clusterissuer
```{{exec}}

Enable OIDC authentication for Application Quality?
```
no
```{{exec}}

The configuration script will generate the necessary Helm values. Let's verify the output files:

```
ls -la generated-*.yaml
```{{exec}}

Have a look at the generated values to understand the configuration:

```
head -50 generated-values.yaml
```{{exec}}
