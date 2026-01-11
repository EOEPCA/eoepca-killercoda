
## Monitoring

### View All Resources

```bash
kubectl get all -n openeo
```{{exec}}

### Check Argo Workflows

```bash
kubectl get workflows -n openeo
```{{exec}}

### View Executor Logs

To see logs from a completed executor:

```bash
kubectl logs -n openeo -l workflows.argoproj.io/workflow --tail=50
```{{exec}}

### View OpenEO API Logs

```bash
kubectl logs -n openeo deploy/openeo-openeo-argo -c openeo-argo --tail=20
```{{exec}}