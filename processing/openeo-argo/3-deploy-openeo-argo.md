## Deploy OpenEO ArgoWorkflows

### Add the Helm repositories

The chart and its dependencies (Argo Workflows, Dask Gateway, PostgreSQL, Redis) are all published to public Helm repositories:

```bash
helm repo add eodc https://eodcgmbh.github.io/charts/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add dask https://helm.dask.org
helm repo update
```{{exec}}

### Apply secrets

The chart expects a pre-existing Secret holding the PostgreSQL admin password rather than generating one itself:

```bash
bash apply-secrets.sh
```{{exec}}

### Deploy

This installs the API/queue-worker deployment along with its bundled PostgreSQL, Redis, Argo Workflows and Dask Gateway dependencies into the `openeo` namespace:

```bash
helm upgrade -i openeo eodc/openeo-argo \
  --version 2026.7.1 \
  --namespace openeo \
  --create-namespace \
  --values generated-values.yaml \
  --dependency-update \
  --timeout 10m
```{{exec}}

Check the pods:

```bash
kubectl get pods -n openeo
```{{exec}}

The chart creates the API's Argo Workflows service-account token via a `post-upgrade` hook, which doesn't run on a first-ever install (Helm only fires `post-install` hooks then). If the `openeo-openeo-argo` pod is stuck in `CreateContainerConfigError` with `secret "openeo-argo-access-sa.service-account-token" not found`, just re-run the same `helm upgrade` command again and the hook will fire:

```bash
helm upgrade -i openeo eodc/openeo-argo \
  --version 2026.7.1 \
  --namespace openeo \
  --create-namespace \
  --values generated-values.yaml \
  --dependency-update \
  --timeout 10m
```{{exec}}

Wait for the main deployment and summarize all OpenEO pods. The `openeo-openeo-argo` pod should reach `2/2 Running` (the API container and its queue worker):

```bash
kubectl rollout status deployment/openeo-openeo-argo \
  -n openeo --timeout=300s
kubectl get pods -n openeo
```{{exec}}

PostgreSQL, Redis, Argo Workflows and Dask Gateway should also all be running.
