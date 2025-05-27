
## Environment Configuration

Start by running the script below. It will guide you through setting the main IAM deployment options:

```bash
bash configure-iam.sh
```

The script will ask for:

- **INGRESS_HOST**: The main domain for IAM endpoints (e.g., `example.com`). All IAM services will use subdomains of this. For this tutorial, use `todo`.
- **STORAGE_CLASS**: The Kubernetes StorageClass for persistent volumes. Use `standard` (default for most clusters).
- **CLUSTER_ISSUER**: The cert-manager ClusterIssuer for TLS certificates. Use `letsencrypt-http01-apisix` (already set up for this environment).

The script will securely store all generated passwords (Keycloak admin, Keycloak DB, OPA client secret) in the `~/.eoepca/state` file for use in later steps.
