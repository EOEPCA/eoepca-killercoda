
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
```{{exec}}

<!--
# REMOVE_ME
# Then also apply the APISIX TLS configuration:

# ```bash
# kubectl apply -f apisix-tls.yaml
# ```{{exec}}
# REMOVE_ME (end)
-->

### Verifying the Deployment

Check the status of the IAM deployment:

```bash
kubectl get pods -n iam
```{{exec}}

Wait for all IAM pods to be `Running`, which may take ~5 minutes to complete:

```bash
kubectl -n iam rollout status \
  deployment.apps/iam-opal-client \
  deployment.apps/iam-opal-pgsql \
  deployment.apps/iam-opal-server \
  deployment.apps/identity-api \
  statefulset.apps/iam-keycloak \
  statefulset.apps/iam-postgresql
```{{exec}}

Once all pods are running and ready, you can check the Keycloak and OPA services.<br>
Don't move on until the below command returns a successful response:

```bash
curl -k http://auth.eoepca.local/realms/eoepca/.well-known/openid-configuration | jq
```{{exec}}
