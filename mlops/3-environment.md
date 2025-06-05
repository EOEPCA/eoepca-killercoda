
## Environment Configuration

Start by running the configuration script below. It will prompt you to set up the MLOps building block's key configuration:

```bash
bash configure-mlops.sh
```

It prompts you for:

- **Ingress Host**: `eoepca.local`
- **Storage Class**: `local-path`
- **S3 endpoint & credentials** (already available from the MinIO setup)
- **OIDC Configuration**: Enable (`true`) and provide the Keycloak URL, or disable (`false`).
    

Alternatively, pre-configure using the following without prompts:

```bash
bash configure-mlops.sh <<EOF
eoepca.local
local-path
https://minio.eoepca.local
us-east-1
{{S3_ACCESS_KEY}}
{{S3_SECRET_KEY}}
mlops-sharinghub
mlops-mlflow
EOF
```{{exec}}

Generated configuration and secrets will be stored securely in `~/.eoepca/state`.
