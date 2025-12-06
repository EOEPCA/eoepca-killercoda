## Running a Job

### Create a Job

Submit a job that loads from our test collection:

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
            "id": "test",
            "spatial_extent": {"west": 11.4, "south": 46.5, "east": 11.5, "north": 46.6},
            "temporal_extent": ["2024-06-01", "2024-06-10"]
          }
        },
        "save": {
          "process_id": "save_result",
          "arguments": {
            "data": {"from_node": "load"},
            "format": "JSON"
          },
          "result": true
        }
      }
    },
    "title": "Test Job"
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
  "title": "Test Job"
}
```

### View Workflow Status

```bash
kubectl get workflows -n openeo
```{{exec}}

You should see the workflow with `STATUS: Succeeded`.

### Verify Output

The job generates a STAC collection in the user workspace. View the output:

```bash
USER_ID="a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
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

This confirms the job executed successfully and generated output. The STAC collection is empty because our mock catalogue has no actual data items, but the entire processing pipeline ran correctly.

With a real STAC catalogue containing Earth observation data, the output would include processed raster files in the `RESULTS` directory.