## Monitoring and Troubleshooting

Summarize the OpenEO namespace:

```bash
kubectl get pods,services,pvc -n openeo
```{{exec}}

Inspect Argo workflow history:

```bash
kubectl get workflows -n openeo \
  --sort-by=.metadata.creationTimestamp
```{{exec}}

Show the newest workflow and its executor pod:

```bash
WORKFLOW=$(
  kubectl get workflows -n openeo \
    --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[-1:].metadata.name}'
)

kubectl describe workflow "${WORKFLOW}" -n openeo | tail -40
kubectl get pods -n openeo \
  -l workflows.argoproj.io/workflow="${WORKFLOW}"
```{{exec}}

Check the API and queue worker logs without streaming:

```bash
kubectl logs -n openeo deploy/openeo-openeo-argo \
  -c openeo-argo --tail=30

kubectl logs -n openeo deploy/openeo-openeo-argo \
  -c openeo-argo-queue-worker --tail=50
```{{exec}}

If a deployment stalls, inspect recent events:

```bash
kubectl get events -n openeo \
  --sort-by=.lastTimestamp | tail -30
```{{exec}}
