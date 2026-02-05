
First, we need to deploy the Resource Discovery BB which will serve as our STAC catalog. For detailed information about Resource Discovery, see the [dedicated tutorial](https://killercoda.com/eoepca/scenario/resource-discovery).

### Configure Resource Discovery

```
cd ~/deployment-guide/scripts/resource-discovery
bash configure-resource-discovery.sh
```{{exec}}

Accept the defaults:
```
no
no
```{{exec}}

### Deploy with Helm

Add the helm repository and deploy:

```
helm repo add eoepca https://eoepca.github.io/helm-charts
helm repo update eoepca
```{{exec}}

```
helm upgrade -i resource-discovery eoepca/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.0.0 \
  --namespace resource-discovery \
  --create-namespace \
  --set db.volume_access_modes=ReadWriteOnce
```{{exec}}

Create the ingress:

```
kubectl apply -f generated-ingress.yaml
```{{exec}}

### Wait for Deployment

Wait for the Resource Discovery service to be ready:

```
while [[ `curl -s -o /dev/null -w "%{http_code}" "http://resource-catalogue.eoepca.local/stac"` != 200 ]]; do sleep 1; done
echo "Resource Discovery is ready!"
```{{exec}}

### Verify Deployment

```
curl -s "http://resource-catalogue.eoepca.local/stac" | jq '{title: .title, description: .description}'
```{{exec}}

The Resource Discovery BB is now running and ready for data ingestion.

# Ingest Data


Now let's ingest a datacube-ready STAC collection. This collection includes the STAC Datacube Extension which defines dimensions and variables.

### Understanding Datacube-Ready Collections

A datacube-ready collection includes:
- **`cube:dimensions`**: Defines x, y, time, and band dimensions with their extents
- **`cube:variables`**: Describes data variables and their relationship to dimensions

This metadata tells processing tools how to interpret the data as a multi-dimensional array.

### Navigate to Datacube Access Scripts

The datacube-ready collection and items are already provided in the deployment guide:

```
cd ~/deployment-guide/scripts/datacube-access
```{{exec}}

### Examine the Datacube Collection

Let's look at the sample datacube-ready collection:

```
cat collections/datacube-ready-collection/collections.json | jq '{id, title, "cube:dimensions": .["cube:dimensions"] | keys, "cube:variables": .["cube:variables"] | keys}'
```{{exec}}

Notice the `cube:dimensions` section defines:
- **x, y**: Spatial dimensions with extent and EPSG code
- **time**: Temporal dimension with ISO 8601 extent
- **bands**: The spectral bands available (B04, B08, SCL)

### Examine the Items

```
cat collections/datacube-ready-collection/items.json | jq '.[0] | {id, datetime: .properties.datetime, cloud_cover: .properties["eo:cloud_cover"], assets: .assets | keys}'
```{{exec}}

Each item contains geometry, temporal properties, and assets pointing to Cloud-Optimised GeoTIFFs.

### Ingest the Collection

First, register the collection with the Resource Discovery STAC API:

```
curl -X POST 'http://resource-catalogue.eoepca.local/stac/collections/metadata:main/items' \
  -H "Content-Type: application/json" \
  -d @collections/datacube-ready-collection/collections.json | jq '.id'
```{{exec}}

### Ingest the Items

Add the items to the collection:

```
cat collections/datacube-ready-collection/items.json | jq -c '.[]' | while read item; do
  curl -X POST 'http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-datacube/items' \
    -H "Content-Type: application/json" \
    -d "$item" | jq '.id'
done
```{{exec}}

### Verify Ingestion

Check the collection is available:

```
curl -s "http://resource-catalogue.eoepca.local/stac/collections" | jq '.collections[].id'
```{{exec}}

List items in the collection:

```
curl -s "http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-datacube/items" | jq '.features[].id'
```{{exec}}

The datacube-ready collection is now ingested and ready for use with Datacube Access.


