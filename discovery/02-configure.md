Before proceeding with the Resource Discovery building block deployment, we need first to configure it. We can do it with the configuration script `configure-resource-discovery.sh` provided in the EOEPCA deployment guide.

```
bash configure-resource-discovery.sh
```{{exec}}

The script reuses the shared EOEPCA configuration already collected while checking prerequisites in the previous step, then asks a single question specific to Resource Discovery: whether to enable the IAM-protected, writable catalogue endpoint. Answer `yes`, since this tutorial goes on to deploy and use that writable catalogue:

```
yes
```{{exec}}

> Answering `no`{{}} here deploys only a read-only catalogue and skips the IAM/Keycloak integration entirely - a valid option if you only need to serve an existing STAC catalogue and plan to bulk-import data with the Resource Registration Building Block instead.
