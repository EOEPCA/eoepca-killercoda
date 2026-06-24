
Before deploying the Resource Health building block, configure it with the
Deployment Guide script:

```bash
bash configure-resource-health.sh
```{{exec}}

The script will load the general EOEPCA configuration and move to the Resource Health building block specific configuration.

The internal cluster issuer is already configured. Keep the existing value:
```
n
```{{exec}}

The `local-path` storage class is also already configured. Keep it:
```
n
```{{exec}}

Keep the existing domain:
```
no
```{{exec}}

Do not enable OIDC authentication for this demonstration:
```
no
```{{exec}}

The configuration is now complete. Verify the generated files:

```
ls -la generated-*.yaml
```{{exec}}

Inspect the generated ingress configuration:

```
cat generated-ingress.yaml
```{{exec}}
