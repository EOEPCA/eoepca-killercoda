Before proceeding with the Resource Registration building block deployment, we need first to configure it. We can do it with the configuration script `configure-resource-registration.sh`{{}} provided in the EOEPCA deployment guide.

This includes configuration of the URL through which the harvested 'eodata' assets can be retrieved. This tutorial environment uses a proxy to route access to running services. Thus, we have to ensure that this proxied URL is well configured within the deployment.

```bash
source ~/.eoepca/state
EODATA_EXT_URL="$(
  sed "s#PORT#$(awk -v host="$INGRESS_HOST" '$0 ~ ("eodata." host) {print $1}' /tmp/assets/killercodaproxy)#" \
    /etc/killercoda/host
)"
echo "External host for eodata: ${EODATA_EXT_URL}/"
```{{exec}}

Taking note of this URL we can now configure the BB:

```
bash configure-resource-registration.sh
```{{exec}}

The script will load the general EOEPCA configuration and move to the Resource Registration building block specific configuration.

We do not need to update the storage class, we will use what's already set, so we answer `no` to the first question. We use eoepca/eoepca as the username and password for the Operaton workflow engine used for harvesting.

```
n
eoepca
eoepca
```{{exec}}

For the **'base URL through which harvested 'eodata' assets will be accessed'** we use the **EODATA_EXT_URL** proxy URL computed above.<br>Paste this to answer the question.

The script then asks whether to enable harvesting a small sample of Landsat data (requires USGS M2M credentials) and, separately, Sentinel 2 data (requires Copernicus Data Space Ecosystem credentials). Both require an account with the respective data provider, and for Landsat, USGS M2M access also requires a separate Data Access Request that can take several days to be approved - so most attendees should say `no` to both here and use the STAC Catalog harvesting step later, which needs no credentials at all. If you already have working credentials for either provider, see the dedicated **Harvesting Landsat** / **Harvesting Sentinel** steps near the end of this tutorial for the full setup - you can always come back and rerun this configuration step later to enable them.

This tutorial continues without either set of credentials configured:

```
no
no
```{{exec}}

To simplify demonstration we opt not to put the resource registration behind authentication. This tutorial's Data Access BB itself is deployed without IAM too, so the STAC API it registers into does not require authentication either - but the generic STAC-catalog harvester used later still needs an IAM client to be configured for it to start up correctly, so we still enable client support:

```
no
yes
resource-registration
```{{exec}}

Finally we run `apply-secrets.sh`, which stores the Operaton username/password and the IAM client credentials into Kubernetes secrets:

```
bash apply-secrets.sh
```{{exec}}
