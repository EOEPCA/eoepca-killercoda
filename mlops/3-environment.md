The second part is the configuration for the MLOps basic environment. To do so, we can run the configuration script below. It will prompt you to set up the MLOps building block's key configuration:

```bash
bash configure-mlops.sh
```{{exec}}

the script will prompt you for the top-level domain for our EOEPCA services and the storage class to use for data persistence. Both have been configured in the step below, and we do not need to update them

```
no
no
```{{exec}}

the script will then ask you about the details of the object storage. Also this is already pre-configured, so we do not need to update it

```
no
no
no
no
```{{exec}}

the script will now ask for the S3 buckets to use for the SharingHub and for the MLFlow, we can use the default ones

```
mlopbb-sharinghub
mlopbb-mlflow-sharinghub
```{{exec}}

It prompts you for:

- **Ingress Host**:
  `eoepca.local`
- **Storage Class**: `local-path`
- **S3 endpoint & credentials** (already available from the MinIO setup)
- **OIDC Configuration**: Enable (`true`) and provide the Keycloak URL, or disable (`false`).
    

Alternatively, pre-configure using the following without prompts:

```bash
bash configure-mlops.sh <<EOF
n
local-path
https://minio.eoepca.local
us-east-1
{{S3_ACCESS_KEY}}
{{S3_SECRET_KEY}}
mlopbb-sharinghub
mlopbb-mlflow-sharinghub
EOF
```{{exec}}

Generated configuration and secrets will be stored securely in `~/.eoepca/state`.
