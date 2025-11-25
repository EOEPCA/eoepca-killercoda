## Deploying OpenEO ArgoWorkflows

Add required Helm repositories:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add dask https://helm.dask.org
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```{{exec}}

Clone and prepare the OpenEO ArgoWorkflows charts:

```bash
cd /tmp
git clone https://github.com/jzvolensky/charts
cd charts/eodc/openeo-argo
```{{exec}}

Update dependencies:

```bash
helm dependency update
helm dependency build
```{{exec}}

Deploy OpenEO ArgoWorkflows with PostgreSQL and Redis:

```bash
cd /root/deployment-guide/scripts/processing/openeo-argo

helm upgrade -i openeo /tmp/charts/eodc/openeo-argo \
    --namespace openeo \
    --create-namespace \
    --values generated-values.yaml \
    --set global.env.authMethod=basic \
    --set global.env.demoMode=true \
    --wait --timeout 10m
```{{exec}}

Wait for all pods to be ready:

```bash
kubectl wait --for=condition=Ready --timeout=300s \
    pod -l app.kubernetes.io/instance=openeo \
    -n openeo
```{{exec}}