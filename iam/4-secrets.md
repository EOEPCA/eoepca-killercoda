With the IAM configuration ready, the next step is to create the Kubernetes secrets for the credentials and other sensitive values. The `apply-secrets.sh`{{}} script uses information from `~/.eoepca/state`{{}} (set up in the previous step) to create the required resources in your cluster.

To apply the secrets, run:

```bash
bash apply-secrets.sh
```{{exec}}

This script will create Kubernetes Secret objects in the `iam`{{}} namespace. These include things like the Keycloak admin password, the Keycloak PostgreSQL database password, and the OPA client secret. The Helm charts for Keycloak and OPA will use these secrets during deployment.

After running the script, you can check that the secrets were created with:

```bash
kubectl -n iam get secrets
```{{exec}}

You should see secrets such as the following:

```
NAME                TYPE     DATA   AGE
iam-keycloak        Opaque   1      8s
keycloak-admin      Opaque   3      11s
keycloak-provider   Opaque   6      10s
opa-route           Opaque   3      9s
postgresql          Opaque   3      11s
```

These hold the credentials that were generated.
