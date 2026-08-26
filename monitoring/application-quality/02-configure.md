
Before deploying the Application Quality building block, we need to configure it.

This tutorial environment uses a proxy to route access to running services. Pre-configure the public Application Quality URL before running the Deployment Guide script:

```bash
bash /tmp/assets/application-quality-localcoda-access preconfigure
cd ../application-quality
```{{exec}}

```
bash configure-application-quality.sh
```{{exec}}

When prompted, provide the following values. The shared domain/storage/TLS questions were
already answered in the prerequisites step, so this script only asks about settings specific
to Application Quality.

Shared storage class for RWX data: (already set)
```
n
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

Enable optional Grafana dashboards? We don't need these for this tutorial:
```
no
```{{exec}}

Enable optional SonarQube deployment? We don't need this for this tutorial:
```
no
```{{exec}}

The script generates Helm values with OIDC configuration. Now apply the Localcoda access settings and create the Keycloak client for Application Quality:

```bash
bash /tmp/assets/application-quality-localcoda-access postconfigure
```{{exec}}
