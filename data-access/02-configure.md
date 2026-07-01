
Before proceeding with the Data Access building block deployment, we need to configure it.

This tutorial environment uses a proxy to route access to running services. We have to ensure that this public URL is correctly configured for the STAC Manager web UI.

The deployment guide expects `EOAPI_PUBLIC_HOST` to contain only a hostname, without `http://` or `https://`. We also retain the complete external URL in `EOAPI_PUBLIC_URL` for the STAC Manager deployment step.

```bash
source ~/.eoepca/state
EOAPI_PROXY_PORT=$(
  awk -v host="$INGRESS_HOST" '$0 ~ ("eoapi." host) {print $1; exit}' \
    /tmp/assets/killercodaproxy
)
export EOAPI_PUBLIC_URL=$(
  sed "s/PORT/${EOAPI_PROXY_PORT}/" /etc/killercoda/host
)
export EOAPI_PUBLIC_HOST="${EOAPI_PUBLIC_URL#*://}"

printf 'Public URL for eoAPI: %s\n' "$EOAPI_PUBLIC_URL"
```{{exec}}

Now we can run the configuration script `configure-data-access.sh` provided in the EOEPCA deployment guide:

```
bash configure-data-access.sh
```{{exec}}

The script will load the general EOEPCA configuration and move to the Data Access building block specific configuration.

> Some configuration has already been established via the `check-prerequisites`{{}} script, and also by the startup scripts of the tutorial environment. In these cases we can answer `n`{{}} to accept the current value.

Keep `eoepca.local`{{}} as the local domain used by the Data Access services:
```
n
```{{exec}}

Keep `local-path`{{}} as the storage class used for persistent Data Access volumes:
```
n
```{{exec}}

We accept the pre-configured MinIO hostname used to reach the tutorial's S3-compatible object storage:
```
n
```{{exec}}

We accept the pre-configured MinIO access key used to authenticate to object storage:
```
n
```{{exec}}

We accept the pre-configured MinIO secret key paired with that access key:
```
n
```{{exec}}

We accept the pre-configured S3 endpoint used by EOAPI to locate stored objects:
```
n
```{{exec}}

Choose the in-cluster PostgreSQL database managed by the Crunchy Postgres Operator:
```
no
```{{exec}}

Run one PostgreSQL replica, which is sufficient for this tutorial:
```
1
```{{exec}}

Allocate a 1 GiB persistent volume to PostgreSQL:
```
1Gi
```{{exec}}

Disable IAM and Keycloak integration to keep this tutorial deployment unauthenticated:
```
no
```{{exec}}

Enable STAC transactions so the tutorial can create and update collections:
```
yes
```{{exec}}

Disable the EOAPI CloudEvents notifier because this tutorial does not consume change events:
```
no
```{{exec}}

The configuration is now complete. You can verify the generated files:

```
head -50 eoapi/generated-values.yaml
grep -E '^(publicUrl|stacApi):' stac-manager/generated-values.yaml
```{{exec}}

The generated STAC Manager URLs use the cluster's HTTP scheme. In the next step, the Helm command overrides them with the HTTPS Localcoda proxy URL.
