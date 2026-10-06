## Run a Sentinel-2 NDVI Job

Create a batch job. The process graph has four nodes:

- `load` reads the red and near-infrared bands of the registered sample.
- `scale` uses `apply` to run a child process on every pixel. Sentinel-2 L2A bands are stored as integers, and multiplying by the 0.0001 scale factor turns them into floating-point values.
- `ndvi` computes `(nir - red) / (nir + red)`.
- `save` writes the result as NetCDF.

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
        "scale": {
          "process_id": "apply",
          "arguments": {
            "data": {"from_node": "load"},
            "process": {
              "process_graph": {
                "multiply": {
                  "process_id": "multiply",
                  "arguments": {"x": {"from_parameter": "x"}, "y": 0.0001},
                  "result": true
                }
              }
            }
          }
        },
        "ndvi": {
          "process_id": "ndvi",
          "arguments": {
            "data": {"from_node": "scale"},
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

A new job stays in `created` status until it is started:

```bash
curl -fsS "${OPENEO_URL}/jobs/${JOB_ID}" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" | jq '{id, title, status}'
```{{exec}}

Start the job. In openEO, a `POST` to the job's `results` endpoint starts processing. The API queues the job and returns HTTP `202`:

```bash
curl -fsS -X POST "${OPENEO_URL}/jobs/${JOB_ID}/results" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -w '\nHTTP %{http_code}\n'
```{{exec}}

Check the status again. It should now be `queued` or `running`:

```bash
curl -fsS "${OPENEO_URL}/jobs/${JOB_ID}" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" | jq '{id, title, status}'
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

The API checks the workflow every few seconds, so the job reports `finished` shortly after the executor pod completes. If it still shows `running`, wait a few seconds and run it again:

```bash
curl -fsS "${OPENEO_URL}/jobs/${JOB_ID}" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" | jq '{id, title, status}'
```{{exec}}

### Get the result

The job's results are published as a STAC collection. Its `extent` covers the processed area, and `assets` holds the NetCDF file with a signed download link:

```bash
RESULTS=$(curl -fsS "${OPENEO_URL}/jobs/${JOB_ID}/results" \
  -H "Authorization: Bearer ${AUTH_TOKEN}")

echo "$RESULTS" | jq '{extent, assets}'
```{{exec}}

Download the file:

```bash
RESULT_URL=$(echo "$RESULTS" | jq -r '.assets[].href')

curl -fsS "${RESULT_URL}" -o ~/openeo-ndvi.nc

ls -lh ~/openeo-ndvi.nc
```{{exec}}

### Inspect the NDVI values

Open the file with [xarray](https://xarray.dev/) in a Python virtual environment:

```bash
python3 -m venv ~/venv
~/venv/bin/pip install -q xarray h5netcdf h5py

cd ~
~/venv/bin/python - <<'EOF'
import xarray

ndvi = xarray.open_dataset("openeo-ndvi.nc").to_dataarray()
print(ndvi)
print("min:", float(ndvi.min()), "mean:", float(ndvi.mean()), "max:", float(ndvi.max()))
EOF
```{{exec}}

The result is a single time step on the sample's 10 m UTM grid (`crs: EPSG:32631`). Cells outside the cropped sample are `nan`. NDVI ranges from -1 to 1: this area is mostly farmland, so the mean is about 0.6, while water gives values near or below 0.

You now have an NDVI raster computed from two Sentinel-2 bands by a Dask worker inside an Argo Workflow, found through the Resource Discovery catalogue and served back through the openEO API.
