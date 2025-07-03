## Validating the Deployment

Let's verify that the service has been deployed correctly.

### Check the Pod

Check that the `openeo-geopyspark-driver` pod is running.

```bash
kubectl get pods -n openeo
```{{exec}}

### Manual Validation

You can manually check the API endpoints. First, source the state file to get the `INGRESS_HOST`.

```bash
source ~/.eoepca/state
```{{exec}}

Check the main capabilities endpoint (note the URL change and basic auth):

```bash
curl -u openeo:openeo -L http://openeo.${INGRESS_HOST}/ | jq .
```{{exec}}

List the available collections:

```bash
curl -u openeo:openeo -L http://openeo.${INGRESS_HOST}/collections | jq .
```{{exec}}

List the supported processes:

```bash
curl -u openeo:openeo -L http://openeo.${INGRESS_HOST}/processes | jq .
```{{exec}}