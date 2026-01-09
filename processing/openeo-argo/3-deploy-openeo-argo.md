
## Deploying OpenEO ArgoWorkflows

### Add Helm Repositories

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add dask https://helm.dask.org
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```{{exec}}

### Prepare the Charts

```bash
cd /tmp
git clone https://github.com/jzvolensky/charts
cd charts/eodc/openeo-argo
```{{exec}}

```bash
helm dependency update
helm dependency build
```{{exec}}

### Deploy

```bash
cd ~/deployment-guide/scripts/processing/openeo-argo

helm upgrade -i openeo /tmp/charts/eodc/openeo-argo \
    --namespace openeo \
    --create-namespace \
    --values generated-values.yaml \
    --set global.env.authMethod=basic \
    --set global.env.demoMode=true \
    --timeout 15m
```{{exec}}

Wait for all pods to be ready (2/2 for the main pod):

```bash
kubectl get pods -n openeo -w
```{{exec}}

Press `Ctrl+C` once you see `openeo-openeo-argo` showing `2/2 Running`.