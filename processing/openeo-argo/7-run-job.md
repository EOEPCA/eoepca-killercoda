## Run a Sentinel-2 Processing Job

Create a batch job that loads the red and near-infrared bands from our registered sample and writes the result as NetCDF:

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
            "temporal_extent": ["2026-06-12", "2026-06-14"],
            "bands": ["red", "nir"]
          }
        },
        "save": {
          "process_id": "save_result",
          "arguments": {
            "data": {"from_node": "load"},
            "format": "netCDF"
          },
          "result": true
        }
      }
    },
    "title": "Sentinel-2 red/nir subset"
  }'

# The job ID comes back in the OpenEO-Identifier header, not the body
export JOB_ID=$(grep -i '^openeo-identifier:' "${JOB_HEADERS}" | cut -d' ' -f2 | tr -d '\r\n')
echo "Created job: ${JOB_ID}"
```{{exec}}

A job sits in `created` status until started:

```bash
curl -fsS -X POST "${OPENEO_URL}/jobs/${JOB_ID}/results" \
  -H "Authorization: Bearer ${AUTH_TOKEN}"
echo
```{{exec}}

Argo creates an executor pod, and Dask creates a temporary scheduler and worker to do the computation. Watch the workflow until it finishes:

```bash
while true; do
  PHASE=$(kubectl get workflows -n openeo --sort-by=.metadata.creationTimestamp -o jsonpath='{.items[-1:].status.phase}')
  echo "Workflow phase: ${PHASE:-Pending}"
  [[ "$PHASE" == "Succeeded" || "$PHASE" == "Failed" || "$PHASE" == "Error" ]] && break
  sleep 15
done
```{{exec}}

The job's results endpoint confirms the output was published:

```bash
RESULTS=$(curl -fsS "${OPENEO_URL}/jobs/${JOB_ID}/results" -H "Authorization: Bearer ${AUTH_TOKEN}")
jq '{assets: (.assets | keys)}' <<<"${RESULTS}"
```{{exec}}

Download the result:

```bash
RESULT_URL=$(jq -r '.assets | to_entries[0].value.href' <<<"${RESULTS}")

curl -fsS "${RESULT_URL}" \
  -H "Authorization: Bearer ${AUTH_TOKEN}" \
  -o ~/openeo-result.nc

ls -lh ~/openeo-result.nc
```{{exec}}

You now have a NetCDF result generated from two Sentinel-2 bands, computed by a Dask worker inside an Argo Workflow.
