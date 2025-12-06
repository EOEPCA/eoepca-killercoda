
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

### Fix the Executor Image

The upstream executor image is missing a required library (`libexpat`). We'll build a patched version:

```bash
apt-get update && apt-get install -y buildah
```{{exec}}

```bash
buildah bud -t ghcr.io/eodcgmbh/openeo-argoworkflows:executor-2025.5.1-fixed -f /tmp/assets/Dockerfile.executor-fix /tmp
```{{exec}}

Export and import into the k3s containerd runtime:

```bash
buildah push ghcr.io/eodcgmbh/openeo-argoworkflows:executor-2025.5.1-fixed docker-archive:/tmp/executor-fixed.tar
ctr -n k8s.io images import /tmp/executor-fixed.tar
```{{exec}}

Verify the image is available:

```bash
crictl images | grep executor
```{{exec}}

Update the configuration to use the fixed image:

```bash
cd /root/deployment-guide/scripts/processing/openeo-argo
sed -i 's|executor-2025.5.1|executor-2025.5.1-fixed|g' generated-values.yaml
```{{exec}}

### Deploy

```bash
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