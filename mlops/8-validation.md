## Validating the MLOps Deployment

Check the status of the key services:

```bash
kubectl get pods -n gitlab
kubectl get pods -n sharinghub
````

All pods should be in `Running` or `Completed` status.

### Manual Web Checks:

- **GitLab**: Access via `https://gitlab.eoepca.local`
- **SharingHub**: Access via `https://sharinghub.eoepca.local`
- **MLflow**: Access via `https://sharinghub.eoepca.local/mlflow/`
    

### S3 Storage Test:

Confirm S3 access via CLI:

```bash
source ~/.eoepca/state
s3cmd ls s3://mlops-sharinghub \
--host minio.eoepca.local \
--access_key "${MINIO_USER}" \
--secret_key "${MINIO_PASSWORD}"
```{{exec}}

Repeat for the MLflow bucket: `mlops-mlflow`.

If all checks pass, your MLOps setup is ready for use.