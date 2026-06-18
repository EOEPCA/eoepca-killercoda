
Before deploying the Application Quality building block, we need to configure it.

This tutorial environment uses a proxy to route access to running services. Pre-configure the public Application Quality URL before running the Deployment Guide script:

```bash
bash /tmp/assets/application-quality-localcoda-access preconfigure
```{{exec}}

```
bash configure-application-quality.sh
```{{exec}}

When prompted, provide the following values.

Base domain name: (already set)
```
n
```{{exec}}

Storage class for persistent data:
```
local-path
```{{exec}}

No cert manager
```
no
```{{exec}}

Internal cluster issuer: (already set)
```
n
```{{exec}}

Enable OIDC authentication for Application Quality?
```
yes
```{{exec}}

Client ID for Application Quality:
```
application-quality
```{{exec}}

The script generates Helm values with OIDC configuration. Now apply the Localcoda access settings and create the Keycloak client for Application Quality:

```bash
bash /tmp/assets/application-quality-localcoda-access postconfigure
```{{exec}}
