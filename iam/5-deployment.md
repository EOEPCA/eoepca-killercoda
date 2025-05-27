
## Deploying IAM Components

Now that you have configured the IAM environment and applied the necessary secrets, it's time to deploy the IAM components using Helm charts. This will set up Keycloak for identity management and OPA with OPAL for policy enforcement.

```bash
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
helm upgrade -i iam eoepca-dev/iam-bb \
  --version 2.0.0-rc1 \
  --namespace iam \
  --values generated-values.yaml \
  --create-namespace
```

Then also apply the APISIX TLS configuration:

```bash
kubectl apply -f apisix-tls.yaml
```