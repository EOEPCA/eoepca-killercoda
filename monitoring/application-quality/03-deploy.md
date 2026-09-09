
We can now deploy the Application Quality building block.

First, create the namespace and apply secrets:

```
bash apply-secrets.sh
```{{exec}}

The Application Quality BB is deployed from the Helm chart in its GitHub repository. Clone it and
update the chart dependencies:

```
git clone --branch reference-deployment https://github.com/EOEPCA/application-quality.git reference-repo
helm dependency update reference-repo/application-quality-reference-deployment
```{{exec}}

Deploy using Helm with the generated values. The first run pulls the API, frontend and PostgreSQL
images, so it can take a few minutes:

```
helm upgrade -i application-quality reference-repo/application-quality-reference-deployment \
  -f generated-values.yaml \
  -n application-quality \
  --create-namespace \
  --wait \
  --timeout 15m
```{{exec}}

Check the status of all resources:

```
kubectl get all,ingress -n application-quality
```{{exec}}

You should see three components running:

- **application-quality-api** — the backend API, which also runs the Celery worker that submits pipelines to Kubernetes
- **application-quality-db** — PostgreSQL database
- **application-quality-web** — the web portal

The API creates its local admin account before it applies the database migrations, so a first
install cannot create that account, nor load the catalogue of analysis tools and pipelines that
belongs to it. Restart the API once to complete the initialisation:

```
kubectl rollout restart deployment/application-quality-api -n application-quality
kubectl rollout status deployment/application-quality-api -n application-quality --timeout=5m
source ~/.eoepca/state
curl --fail --show-error --silent --retry 30 --retry-all-errors --retry-delay 2 \
  "${HTTP_SCHEME}://${APP_QUALITY_PUBLIC_HOST}/api/tools/" | jq
```{{exec}}

Now create the Keycloak client for Application Quality. The configuration script rendered it as a
Crossplane `Client`{{}} resource:

```
kubectl apply -f generated-iam.yaml
```{{exec}}

Crossplane creates the client in Keycloak. Wait for it to be reconciled:

```
kubectl wait --for=condition=Ready client.openidclient.keycloak.m.crossplane.io/application-quality-bb \
  -n iam-management --timeout=120s
```{{exec}}

Run the validation script to confirm the deployment:

```
bash validation.sh
```{{exec}}

The web portal is now accessible at `{{TRAFFIC_HOST1_81}}`.

[View Application Quality Web Portal]({{TRAFFIC_HOST1_81}})
