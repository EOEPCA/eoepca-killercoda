
Apply the required Kubernetes secrets generated during configuration:

```bash
bash apply-secrets.sh
```{{exec}}

Then run this to apply application credentials to the state:

```bash
bash utils/save-application-credentials-to-state.sh <<EOF
n
n
EOF
```{{exec}}

Verify secrets were created:

```bash
kubectl -n sharinghub get secrets
```{{exec}}

You should see secrets for the mlflow and sharinghub.