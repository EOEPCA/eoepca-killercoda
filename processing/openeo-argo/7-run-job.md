## Run a Sentinel-2 NDVI Job

Create a batch job. The process graph loads the red and near-infrared bands of the registered sample, computes NDVI from them, and writes the result as NetCDF:

```bash
JOB_HEADERS=$(mktemp)

curl -fsS -D "${JOB_HEADERS}" -o /dev/null \
  -X POST "${OPENEO_URL}/jobs" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{
    "process": {
      "process_graph": {
        "load": {
          "process_id": "load_collection",
          "arguments": {
            "id": "sentinel-2-demo",
            "spatial_extent": {"west": 4.998, "south": 52.000, "east": 5.052, "north": 52.050},
            "temporal_extent": ["2026-06-24", "2026-06-26"],
            "bands": ["red", "nir"]
          }
        },
        "ndvi": {
          "process_id": "ndvi",
          "arguments": {
            "data": {"from_node": "load"},
            "red": "red",
            "nir": "nir"
          }
        },
        "save": {
          "process_id": "save_result",
          "arguments": {
            "data": {"from_node": "ndvi"},
            "format": "netCDF"
          },
          "result": true
        }
      }
    },
    "title": "Sentinel-2 NDVI"
  }'

# The job ID comes back in the OpenEO-Identifier header, not the body
export JOB_ID=$(grep -i '^openeo-identifier:' "${JOB_HEADERS}" | cut -d' ' -f2 | tr -d '\r\n')
echo "Created job: ${JOB_ID}"
```{{exec}}

A job sits in `created` status until started:

```bash
curl -fsS "${OPENEO_URL}/jobs/${JOB_ID}" \
  -H "Authorization: Bearer ${AUTH_TOKEN}"
echo
```{{exec}}

Argo runs the job in an executor pod, which asks Dask Gateway for a temporary scheduler and worker to do the computation. Run this a couple of times while the job is running to watch them come and go:

```bash
kubectl get pods -n openeo
```{{exec}}

The executor pod is labelled with the OpenEO job ID. Wait for it to finish - this takes about a minute:

```bash
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod -n openeo \
  -l "OPENEO_JOB_ID=${JOB_ID},workflows.argoproj.io/workflow" --timeout=600s
```{{exec}}

If this reports `no matching resources found`, the executor pod has not been created yet - run it again.

The access token from step 6 has a short lifetime and may have expired while the job ran. Get a fresh one:

```bash
source ~/.eoepca/state

ACCESS_TOKEN=$(curl -s -X POST \
    "${OIDC_ISSUER_URL}/protocol/openid-connect/token" \
    -d "grant_type=password" \
    -d "username=${KEYCLOAK_TEST_USER}" \
    -d "password=${KEYCLOAK_TEST_PASSWORD}" \
    -d "client_id=openeo-argo" \
    -d "scope=openid" | jq -r '.access_token')
export AUTH_TOKEN="oidc/${OIDC_ORGANISATION}/${ACCESS_TOKEN}"
```{{exec}}

The job's results endpoint lists the published assets:

```bash
RESULTS=$(curl -fsS "${OPENEO_URL}/jobs/${JOB_ID}/results" -H "Authorization: Bearer ${AUTH_TOKEN}")
jq '{assets: (.assets | keys)}' <<<"${RESULTS}"
```{{exec}}

Download the result:

```bash
RESULT_URL=$(jq -r '.assets | to_entries[0].value.href' <<<"${RESULTS}")

curl -fsS "${RESULT_URL}" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -o ~/openeo-ndvi.nc

ls -lh ~/openeo-ndvi.nc
```{{exec}}

You now have an NDVI raster computed from two Sentinel-2 bands by a Dask worker inside an Argo Workflow. To see it as an image, open the job in the [OpenEO Web Editor](https://editor.openeo.org?server={{TRAFFIC_HOST1_81}}/openeo/1.1.0/) from step 6 and select it under **Data Processing**.
