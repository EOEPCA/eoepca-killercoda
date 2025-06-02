
## Environment Configuration

Start by running the script below. It will guide you through setting the main IAM deployment options:

```bash
bash configure-iam.sh
```

The script will ask for:

- **Ingress Host**: `eoepca.local`
- **Storage Class**: `local-path` (already set up for this environment)
- **Keycloak Realm Name**: `eoepca`
- **Cluster Issuer**: `selfsigned-issuer` (already set up for this environment).
- **OPA Client ID**: `opa`
- **Identity API Client ID**: `identity-api`

Alternatively run this which will set the same values without prompts:

```bash
bash configure-iam.sh <<EOF
eoepca.local
local-path
eoepca
selfsigned-issuer
opa
identity-api
EOF
```{{exec}}

```bash
source ../common/utils.sh
add_to_state_file "KEYCLOAK_HOST" auth.eoepca.local:31443
```{{exec}}

The script will securely store all generated passwords (Keycloak admin, Keycloak DB, OPA client secret) in the `~/.eoepca/state` file for use in later steps.
