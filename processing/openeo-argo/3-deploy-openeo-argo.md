## Deploy OpenEO ArgoWorkflows

### Prepare the Helm chart

Add the dependency repositories:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add dask https://helm.dask.org
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```{{exec}}

Clone the chart revision validated for this workshop and download its dependencies:

```bash
cd /tmp
git clone https://github.com/jzvolensky/charts
cd charts
git checkout 301f1a7
cd eodc/openeo-argo
helm dependency build
```{{exec}}

### Prepare the executor image

The published executor mishandles STAC assets that provide `eo:bands` but no `raster:bands`. Build a thin local image containing the corrected loader and import it into k3s:

```bash
bash /tmp/assets/prepare-openeo-executor-image
```{{exec}}

### Deploy

```bash
cd ~/deployment-guide/scripts/processing/openeo-argo

helm upgrade -i openeo /tmp/charts/eodc/openeo-argo \
  --namespace openeo \
  --create-namespace \
  --values generated-values.yaml \
  --set global.env.executorImage=docker.io/eoepca/openeo-argoworkflows:executor-localcoda \
  --timeout 15m
```{{exec}}

The chart revision currently attaches HTTP probes to the queue worker, although that worker does not serve HTTP. Remove those two invalid probes:

```bash
kubectl patch deployment openeo-openeo-argo -n openeo --type=json -p='[
  {"op":"remove","path":"/spec/template/spec/containers/1/livenessProbe"},
  {"op":"remove","path":"/spec/template/spec/containers/1/readinessProbe"}
]'
```{{exec}}

Wait for the main deployment and summarize all OpenEO pods:

```bash
kubectl rollout status deployment/openeo-openeo-argo \
  -n openeo --timeout=300s
kubectl get pods -n openeo
```{{exec}}

The `openeo-openeo-argo` pod should show `2/2 Running`. PostgreSQL, Redis, Argo Workflows, and Dask Gateway should also be running.
