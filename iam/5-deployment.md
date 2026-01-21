Now that you have configured the IAM environment and applied the necessary secrets, it's time to deploy the IAM components using Helm charts. This will set up Keycloak for identity management and OPA with OPAL for policy enforcement.

```bash
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
helm upgrade -i iam eoepca-dev/iam-bb \
  --version 2.0.0-rc2 \
  --namespace iam --create-namespace \
  --values generated-values.yaml
```{{exec}}

Now you can check the status of the IAM deployment:

```bash
kubectl get pods -n iam
```{{exec}}

Wait for all IAM pods to be `Running`{{}}, which may take ~5 minutes to complete:

```bash
kubectl -n iam rollout status \
  deployment.apps/iam-opal-server \
  deployment.apps/iam-opal-pgsql \
  statefulset.apps/iam-postgresql \
  deployment.apps/iam-opal-client \
  statefulset.apps/iam-keycloak
```{{exec}}

> DO NOT proceed until the above command completes, indicating that the IAM pods are now running.

## Check Keycloak Service

Once all pods are running and ready, you can check the Keycloak service discovery endpoint...

> There may still be a short delay until the IAM services are ready and responding to requests.

```bash
curl -k http://auth.eoepca.local/realms/master/.well-known/openid-configuration | jq
```{{exec}}

## Check Keycloak UI

> NOTE that the Keycloak service takes some time to accept connections following startup.

At this point we can check access to the [Keycloak Web UI]({{TRAFFIC_HOST1_90}}) - using the `admin`{{}} credentials defined in the `~/.eoepca/state`{{}} file.

```bash
grep KEYCLOAK_ADMIN_ ~/.eoepca/state
```{{exec}}
