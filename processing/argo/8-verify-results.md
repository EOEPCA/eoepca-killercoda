Once the workflow completes, let's verify the results were properly stored in MinIO.

First, check the job results through the OGC API:

```bash
curl -s http://localhost:8080/ogc-api/jobs/${JOB_ID}/results | jq .
```{{exec}}

The results should be staged in the MinIO `results` bucket. List the contents:

```bash
mc ls -r local-minio/results/
```{{exec}}

You should see a directory structure with your job results. Let's look at the STAC catalog that was created:

```bash
# Find the catalog.json file
mc find local-minio/results --name "catalog.json" --exec "mc cat {}" | jq .
```{{exec}}

You can also view the workflow details in Argo to see the execution steps:

```bash
# Get the workflow name
WORKFLOW_NAME=$(kubectl get workflows -n ns1 --no-headers | tail -1 | awk '{print $1}')

# View the workflow status
kubectl get workflow ${WORKFLOW_NAME} -n ns1 -o yaml | grep -A10 "phase:"
```{{exec}}
