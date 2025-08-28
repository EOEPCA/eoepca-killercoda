## Validating the Deployment

### Check Pods Status

Verify all pods are running correctly:

```bash
kubectl get pods -n openeo-geotrellis
```{{exec}}

Expected pods:
- Spark Operator controller and webhook
- ZooKeeper
- OpenEO driver and executor
