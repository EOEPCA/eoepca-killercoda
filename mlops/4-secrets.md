
Apply the required Kubernetes secrets generated during configuration:

```bash
bash apply-secrets.sh
```{{exec}}

Verify secrets were created:

```bash
kubectl -n sharinghub get secrets
```{{exec}}

You’ll see secrets for S3 credentials and MLflow databases.