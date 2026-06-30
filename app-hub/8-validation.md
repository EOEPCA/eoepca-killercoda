
## Validation

### Automated Validation

Run the validation script to check the deployment:

```bash
bash validation.sh
```{{exec}}

Check the spawned profile:

```bash
kubectl get pods -n ws-eric
```{{exec}}

The STAC Browser pod should show `1/1` containers ready and `Running` status.
