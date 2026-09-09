
Before deploying the Application Quality building block, we need to configure it.

This tutorial environment uses a proxy to route access to running services. The ingress, the web
portal URL and the Keycloak client must all use that public URL, so we set it before running the
Deployment Guide script:

```bash
APP_QUALITY_PUBLIC_URL=$(sed 's/PORT/81/' /etc/killercoda/host)
export APP_QUALITY_PUBLIC_HOST="${APP_QUALITY_PUBLIC_URL#*://}"
echo "$APP_QUALITY_PUBLIC_URL"
```{{exec}}

Now run the configuration script:

```
bash configure-application-quality.sh
```{{exec}}

The shared domain/storage/TLS questions were already answered in the prerequisites step, so this
script only asks about settings specific to Application Quality.

Shared storage class for the Calrissian workflow runner: (already set)
```
n
```{{exec}}

Internal cluster issuer: (already set)
```
n
```{{exec}}

Enable OIDC authentication, so that the portal logs users in through Keycloak:
```
yes
```{{exec}}

Client ID for Application Quality:
```
application-quality-bb
```{{exec}}

Username for the local admin account:
```
admin
```{{exec}}

Email for the local admin account:
```
admin@example.com
```{{exec}}

Enable optional Grafana dashboards? We don't need these for this tutorial:
```
no
```{{exec}}

Enable optional SonarQube deployment? We don't need this for this tutorial:
```
no
```{{exec}}

The script prints the generated OIDC client secret and the generated password for the local admin
account. Both are stored in `~/.eoepca/state`{{}}, along with the rest of the configuration. The
local admin account owns part of the API's catalogue of analysis tools and pipelines, and we will
use it later to call the API from this terminal.
