
## Deploying IAM Components

Now that you have configured the IAM environment and applied the necessary secrets, it's time to deploy the IAM components using Helm charts. This will set up Keycloak for identity management and OPA with OPAL for policy enforcement.

```bash
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
helm upgrade -i iam eoepca-dev/iam-bb \
  --version 2.0.0-rc1 \
  --namespace iam --create-namespace \
  --values generated-values.yaml
```{{exec}}

### Wait for deployment completion

Check the status of the IAM deployment:

```bash
kubectl get pods -n iam
```{{exec}}

Wait for all IAM pods to be `Running`, which may take ~5 minutes to complete:

```bash
kubectl -n iam rollout status \
  deployment.apps/iam-opal-server \
  deployment.apps/iam-opal-pgsql \
  statefulset.apps/iam-postgresql \
  deployment.apps/iam-opal-client \
  statefulset.apps/iam-keycloak \
  deployment.apps/identity-api
```{{exec}}

> DO NOT proceed until the above command completes, indicating that the IAM services are deployed.

### Check services

Once all pods are running and ready, you can check the Keycloak service discovery endpoint...

```bash
curl -k http://auth.eoepca.local/realms/eoepca/.well-known/openid-configuration | jq
```{{exec}}
