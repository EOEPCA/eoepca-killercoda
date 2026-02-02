
Before proceeding with the Data Access building block deployment, we need to configure it.

This tutorial environment uses a proxy to route access to running services. We have to ensure that this proxied URL is well configured within the deployment - in particular for the STAC Manager web UI. Thus, we pre-configure here the environment variable `EOAPI_PUBLIC_HOST` which is deduced from the running enviornment.

```bash
source ~/.eoepca/state
export EOAPI_PUBLIC_HOST="$(
  sed "s#http://PORT#$(awk -v host="$INGRESS_HOST" '$0 ~ ("eoapi." host) {print $1}' /tmp/assets/killercodaproxy)#" \
    /etc/killercoda/host
)"
echo -e "\nPublic host for eoAPI: ${EOAPI_PUBLIC_HOST}"
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
```{{exec}}
