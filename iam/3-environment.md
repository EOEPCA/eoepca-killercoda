
## Environment Configuration

Start by running the script below. It will guide you through setting the main IAM deployment options:

```bash
bash configure-iam.sh
```

The script will ask for:

- **INGRESS_HOST**: `eoepca.local`
- **STORAGE_CLASS**: `local-path` (already set up for this environment)
- **Keycloak Realm Name**: `eoepca`
- **CLUSTER_ISSUER**: `selfsigned-issuer` (already set up for this environment).
- **OPA Client ID**: `opa`
- **Identity API Client ID**: `identity-api`

The script will securely store all generated passwords (Keycloak admin, Keycloak DB, OPA client secret) in the `~/.eoepca/state` file for use in later steps.
