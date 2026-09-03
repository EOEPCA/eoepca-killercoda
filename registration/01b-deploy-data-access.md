The Resource Registration BB needs a catalogue to register resources into. This tutorial uses the **Data Access** Building Block's eoAPI STAC endpoint for that - so we deploy a minimal Data Access BB here: only the STAC API and its database, without Raster, Vector, Multidim, STAC Manager or titiler-openeo, none of which this tutorial uses.

```
cd ~/deployment-guide/scripts/data-access
```{{exec}}

Data Access requires an S3-compatible object store, used by its Raster/Vector/Multidim services. Since this tutorial only deploys the STAC component, a placeholder value is enough:

```
mkdir -p ~/.eoepca && echo 'export S3_HOST="minio.eoepca.local"' >> ~/.eoepca/state
source ~/.eoepca/state
```{{exec}}

```
bash check-prerequisites.sh
```{{exec}}

Now configure the Data Access BB:

```
bash configure-data-access.sh
```{{exec}}

We accept the placeholder S3 host, and provide placeholder access/secret keys since they are unused here:
```
n
unused
unused
```{{exec}}

Use the in-cluster PostgreSQL database with a single replica and a small volume:
```
no
1
1Gi
```{{exec}}

Disable IAM - this tutorial's STAC catalogue stays fully open. The Resource Registration BB deployed later still enables its own IAM client, due to a limitation in the harvester explained at that point:
```
no
openeo
```{{exec}}

Enable STAC transactions, since the harvester needs to write into the catalogue, and disable the notifier and geoparquet export, neither of which this tutorial uses:
```
yes
no
no
```{{exec}}

Apply the secrets:
```
bash apply-secrets.sh
```{{exec}}

### Deploy PostgreSQL Operator

```
helm upgrade --install pgo oci://registry.developers.crunchydata.com/crunchydata/pgo \
  --version 5.8.8 \
  --namespace data-access \
  --create-namespace \
  --values postgres/generated-values.yaml \
  --wait
```{{exec}}

### Deploy eoAPI

This tutorial only needs the STAC component, so Raster, Vector and Multidim are disabled to stay within this environment's resource budget:

```
helm repo add eoapi https://developmentseed.org/eoapi-k8s/
helm repo update eoapi
helm upgrade -i eoapi eoapi/eoapi \
  --version 0.13.1 \
  --namespace data-access \
  --create-namespace \
  --values eoapi/generated-values.yaml \
  --set raster.enabled=false \
  --set vector.enabled=false \
  --set multidim.enabled=false \
  --set stac.autoscaling.minReplicas=1 \
  --set stac.autoscaling.maxReplicas=1 \
  --timeout 10m
```{{exec}}

### Create Ingress

```
kubectl apply -f eoapi/generated-ingress.yaml
```{{exec}}

> This also creates routes for Raster, Vector, Multidim, STAC Manager and titiler-openeo, none of which are deployed in this tutorial - requests to those specific paths will fail, `/stac` and `/browser` are unaffected. It also fails to create two `Certificate` resources, since cert-manager isn't installed in this tutorial - expected, as this tutorial doesn't use HTTPS.

### Wait for Readiness

```
kubectl wait --for=condition=Available deployment/eoapi-stac -n data-access --timeout=300s
kubectl wait --for=jsonpath='{.status.readyReplicas}'=1 statefulset \
  --selector postgres-operator.crunchydata.com/cluster=eoapi \
  --namespace data-access \
  --timeout=300s
```{{exec}}

### Validate

```
curl -s http://eoapi.eoepca.local/stac/ | jq '{type, stac_version}'
```{{exec}}

You should see a valid STAC Catalog document. The STAC API is now available at [this link]({{TRAFFIC_HOST1_89}}/stac/), or within the cluster at `http://eoapi.eoepca.local/stac/`. Its bundled STAC Browser is at [this link]({{TRAFFIC_HOST1_89}}/browser/), used later to visualise harvested resources.
