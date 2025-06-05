
Apply the required Kubernetes secrets generated during configuration:

```bash
bash apply-secrets.sh
```{{exec}}

Verify secrets were created:

```bash
kubectl -n sharinghub get secrets
```{{exec}}

You should see secrets for the mlflow and sharinghub.