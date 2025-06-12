## Validating the Deployment

Let's verify that everything has been deployed correctly.

### Automated Validation

Run the provided validation script to check the status of pods and API endpoints.

```bash
bash validation.sh
```{{exec}}

The script will confirm that all pods are running and key API endpoints are responding correctly.

### Manual Validation

You can also manually check the API endpoints. First, source the state file to get the `INGRESS_HOST`.

```bash
source ~/.eoepca/state
```{{exec}}

Check the API metadata:

```bash
curl -L https://openeo.${INGRESS_HOST}/openeo/1.2/ | jq .
```{{exec}}

List the available collections:

```bash
curl -L https://openeo.${INGRESS_HOST}/openeo/1.2/collections | jq .
```{{exec}}

List the supported processes:

```bash
curl -L https://openeo.${INGRESS_HOST}/openeo/1.2/processes | jq .
```{{exec}}