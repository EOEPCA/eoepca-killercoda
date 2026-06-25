## Run a Sentinel-2 Processing Job

Create a batch job that loads the red (`B04`) and near-infrared (`B08`) bands over a small area, then writes the result as NetCDF. The smaller extent keeps the workshop job quick while still reading real public Sentinel-2 COGs.

```bash
JOB_HEADERS=$(mktemp)

curl -fsS -D "${JOB_HEADERS}" -o /dev/null \
  -u "${OPENEO_USER}:${OPENEO_PASSWORD}" \
  -X POST \
  -H 'Content-Type: application/json' \
  "${OPENEO_URL}/jobs" \
  -d '{
    "process": {
      "process_graph": {
        "load": {
          "process_id": "load_collection",
          "arguments": {
            "id": "sentinel-2-datacube",
            "spatial_extent": {
              "west": -33.80,
              "south": 40.75,
              "east": -33.75,
              "north": 40.80
            },
            "temporal_extent": ["2025-10-29", "2025-10-31"],
            "bands": ["B04", "B08"]
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
    "title": "Sentinel-2 B04/B08 subset"
  }'

export JOB_ID=$(
  awk 'BEGIN {IGNORECASE=1}
       /^openeo-identifier:/ {gsub("\r", "", $2); print $2}' \
    "${JOB_HEADERS}"
)
echo "Created job: ${JOB_ID}"
```{{exec}}

Start the job:

```bash
export WORKFLOW_COUNT=$(
  kubectl get workflows -n openeo \
    --sort-by=.metadata.creationTimestamp \
    -o json | jq '.items | length'
)

curl -fsS -u "${OPENEO_USER}:${OPENEO_PASSWORD}" \
  -X POST "${OPENEO_URL}/jobs/${JOB_ID}/results"
echo
```{{exec}}

Argo creates an executor pod and Dask creates a temporary scheduler and worker. Poll every 30 seconds until the newest workflow reaches a terminal phase:

```bash
for attempt in $(seq 1 20); do
  workflow=$(
    kubectl get workflows -n openeo \
      --sort-by=.metadata.creationTimestamp \
      -o json \
      | jq -r --argjson index "${WORKFLOW_COUNT}" '
          .items[$index] // {}
          | if .metadata.name
            then "\(.metadata.name) \(.status.phase // "Pending")"
            else "waiting for workflow"
            end
        '
  )
  echo "attempt ${attempt}/20: ${workflow}"
  case "${workflow}" in
    *Succeeded|*Failed|*Error) break ;;
  esac
  sleep 30
done
```{{exec}}

The job metadata endpoint can briefly lag behind Argo. The results endpoint is the definitive validation that output was published:

```bash
RESULTS=$(
  curl -fsS -u "${OPENEO_USER}:${OPENEO_PASSWORD}" \
    "${OPENEO_URL}/jobs/${JOB_ID}/results"
)

jq '{
  id,
  status: .["openeo:status"],
  bbox: .extent.spatial.bbox[0],
  assets: (.assets | keys)
}' <<<"${RESULTS}"
```{{exec}}

Download the first result asset through the authenticated ingress:

```bash
RESULT_URL=$(jq -r '.assets | to_entries[0].value.href' <<<"${RESULTS}")

curl -fsS -u "${OPENEO_USER}:${OPENEO_PASSWORD}" \
  "${RESULT_URL}" \
  -o ~/openeo-result.nc

ls -lh ~/openeo-result.nc
```{{exec}}

You now have a real NetCDF result generated from the two Sentinel-2 bands.
