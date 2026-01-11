## Running a Job

### Create a Job

Submit a job that loads Sentinel-2 data from the Resource Discovery catalogue:

```bash
curl -s -u eoepcauser:eoepcapass -X POST \
  -H "Content-Type: application/json" \
  http://openeo.eoepca.local/jobs \
  -d '{
    "process": {
      "process_graph": {
        "load": {
          "process_id": "load_collection",
          "arguments": {
            "id": "sentinel-2-datacube",
            "spatial_extent": {"west": -34.0, "south": 40.5, "east": -33.5, "north": 41.0},
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
    "title": "Sentinel-2 Processing Job"
  }' | jq .
```{{exec}}

### Start the Job

Get the job ID and start execution:

```bash
JOB_ID=$(curl -s -u eoepcauser:eoepcapass http://openeo.eoepca.local/jobs | jq -r '.jobs[-1].id')
echo "Starting job: $JOB_ID"

curl -s -u eoepcauser:eoepcapass -X POST \
  http://openeo.eoepca.local/jobs/${JOB_ID}/results
```{{exec}}

### Monitor Execution

Watch the pods to see the executor and Dask workers spin up:

```bash
kubectl get pods -n openeo -w
```{{exec}}

Press `Ctrl+C` once you see the executor pod reach `Completed` status.

You should see:
- `openeo-executor-*` pod start and complete
- `dask-scheduler-*` pod spin up temporarily
- `dask-worker-*` pod spin up temporarily

### Check Job Status

```bash
curl -s -u eoepcauser:eoepcapass http://openeo.eoepca.local/jobs/${JOB_ID} | jq '{id, status, title}'
```{{exec}}

Expected output:
```json
{
  "id": "<job-id>",
  "status": "finished",
  "title": "Sentinel-2 Processing Job"
}
```

### View Workflow Status

```bash
kubectl get workflows -n openeo
```{{exec}}

You should see the workflow with `STATUS: Succeeded`.

### Verify Output

The job generates a STAC collection and result files in the user workspace:

```bash
USER_ID="a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
kubectl exec -n openeo deploy/openeo-openeo-argo -c openeo-argo -- \
  ls -la /user_workspaces/${USER_ID}/${JOB_ID}/RESULTS/
```{{exec}}

View the STAC collection metadata:

```bash
kubectl exec -n openeo deploy/openeo-openeo-argo -c openeo-argo -- \
  cat /user_workspaces/${USER_ID}/${JOB_ID}/STAC/${JOB_ID}_collection.json | jq '{type, id, description}'
```{{exec}}

Expected output:
```json
{
  "type": "Collection",
  "id": "<job-id>",
  "description": "The STAC Collection representing the output of job <job-id>"
}
```

The RESULTS directory contains a NetCDF file with the processed Sentinel-2 bands (B04 red and B08 NIR) clipped to the requested spatial extent.