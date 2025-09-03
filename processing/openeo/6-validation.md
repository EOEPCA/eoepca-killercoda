## Validating the Deployment

### Check Pods Status

Verify all pods are running correctly:

```bash
bash validation.sh
```{{exec}}

Expected pods:
- Spark Operator controller and webhook
- ZooKeeper
- OpenEO driver and executor
