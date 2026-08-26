
Before deploying the Resource Health building block, configure it with the
Deployment Guide script:

```bash
bash configure-resource-health.sh
```{{exec}}

The shared domain/storage/TLS questions were already answered in the previous step. This
script only asks about settings specific to Resource Health.

The internal cluster issuer is already configured. Keep the existing value:
```
n
```{{exec}}

OIDC protection for Resource Health currently requires APISIX, and this tutorial uses nginx, so disable it:
```
no
```{{exec}}

Disable email alerting for this demonstration:
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
