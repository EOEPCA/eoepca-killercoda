
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

We accept the `eoepca.local`{{}} top-level domain for our EOEPCA services:
```
n
```{{exec}}

We accept the basic `local-path`{{}} storage class provided in this sandbox:
```
n
```{{exec}}

We accept the pre-configured details for the MinIO S3 object storage:
```
n
n
n
n
```{{exec}}

We will use the internal PostgreSQL (managed by the Crunchy Postgres Operator):
```
no
```{{exec}}

Number of PostgreSQL replicas (1 is sufficient for demo):
```
1
```{{exec}}

PostgreSQL storage size:
```
1Gi
```{{exec}}

For this demonstration, we will not be enabling IAM/Keycloak integration:
```
no
```{{exec}}

Enable STAC transactions extension (allows creating/updating collections):
```
yes
```{{exec}}

We will not enable the CloudEvents notifier for this demo:
```
no
```{{exec}}

The configuration is now complete. You can verify the generated files:

```
head -50 eoapi/generated-values.yaml
grep -E '^(publicUrl|stacApi):' stac-manager/generated-values.yaml
```{{exec}}

The generated STAC Manager URLs use the cluster's HTTP scheme. In the next step, the Helm command overrides them with the HTTPS Localcoda proxy URL.
