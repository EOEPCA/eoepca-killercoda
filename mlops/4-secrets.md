
Apply the required Kubernetes secrets generated during configuration:

```bash
bash apply-secrets.sh
```{{exec}}

Verify secrets were created:

kubectl -n gitlab get secrets

kubectl -n sharinghub get secrets

You’ll see secrets for GitLab OAuth, S3 credentials, and MLflow databases.