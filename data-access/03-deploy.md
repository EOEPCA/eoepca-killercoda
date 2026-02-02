
We can now deploy the Data Access building block.

First, we apply the secrets for S3 access:

```
bash apply-secrets.sh
```{{exec}}

### Deploy PostgreSQL Operator

The Data Access BB uses PostgreSQL with PostGIS and pgSTAC extensions. We'll deploy the Crunchy Postgres Operator to manage the database:

```
helm upgrade --install pgo oci://registry.developers.crunchydata.com/crunchydata/pgo \
  --version 5.6.0 \
  --namespace data-access \
  --create-namespace \
  --values postgres/generated-values.yaml \
  --wait
```{{exec}}

### Deploy eoAPI

Now we deploy the core eoAPI services:

```
helm repo add eoapi https://devseed.com/eoapi-k8s/
helm repo update eoapi
helm upgrade -i eoapi eoapi/eoapi \
  --version 0.7.12 \
  --namespace data-access \
  --values eoapi/generated-values.yaml \
  --timeout 10m
```{{exec}}

> While it is deploying you can [read about what eoAPI is](https://eoapi.dev/)

### Deploy STAC Manager

The STAC Manager provides a web UI for catalogue administration:

```
helm repo add stac-manager https://stac-manager.ds.io/
helm repo update stac-manager
helm upgrade -i stac-manager stac-manager/stac-manager \
  --version 0.0.11 \
  --namespace data-access \
  --values stac-manager/generated-values.yaml
```{{exec}}

### Deploy EOAPI Maps Plugin

The Maps Plugin adds OGC API Maps support:

```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev/
helm repo update eoepca-dev
helm upgrade -i eoapi-maps-plugin eoepca-dev/eoapi-maps-plugin \
  --version 0.0.21 \
  --namespace data-access \
  --values eoapi-maps-plugin/generated-values.yaml
```{{exec}}

### Wait for Services

Now we wait for all Data Access pods to start. This may take some time, especially for the database initialisation:

```
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l postgres-operator.crunchydata.com/cluster=eoapi -n data-access --timeout=300s 2>/dev/null || true

echo "Waiting for eoAPI pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=eoapi -n data-access --timeout=300s 2>/dev/null || true

echo "Waiting for STAC Manager to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=stac-manager -n data-access --timeout=120s 2>/dev/null || true
```{{exec}}

Let's check the status of all resources:

```
kubectl get all -n data-access
```{{exec}}

### Validate Deployment

We can validate the deployment using the provided validation script:

```
bash validation.sh nomonitoring
```{{exec}}

Once deployed, the Data Access services should be accessible:
- STAC API: [Access here]({{TRAFFIC_HOST1_82}}/stac/)
- Raster API: [Access here]({{TRAFFIC_HOST1_82}}/raster/)
- Vector API: [Access here]({{TRAFFIC_HOST1_82}}/vector/)
- STAC Manager: [Access here]({{TRAFFIC_HOST1_82}}/manager/)
