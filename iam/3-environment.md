
## Environment Configuration

Start by running the script below. It will guide you through setting the main IAM deployment options:

The IAM building-block is preconfigured with a set of values that are used to configure the helm chart through which it is deployed.<br>
As an aide, the script `configure-iam.sh` {{}} provides a guided approach to configure the values.

The script will ask for:

- **Ingress Host**: `eoepca.local` {{}}
- **Storage Class**: `local-path` {{}} (already set up for this environment)
- **Keycloak Realm Name**: `eoepca` {{}}
- **Cluster Issuer**: `selfsigned-issuer` {{}} (already set up for this environment).
- **OPA Client ID**: `opa` {{}}
- **Identity API Client ID**: `identity-api` {{}}

The following runs the script and set the values without prompts:

```bash
bash configure-iam.sh <<EOF
eoepca.local
local-path
eoepca
opa
identity-api
EOF
```{{exec}}

The script will store all generated passwords (Keycloak admin, Keycloak DB, OPA client secret) in the `~/.eoepca/state` {{}} file for use in later steps.
