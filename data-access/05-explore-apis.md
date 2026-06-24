
Let's explore the various APIs provided by the Data Access building block.

### STAC API - Search

The STAC API supports powerful search queries. Let's search for items within a specific area and time range:

```
curl -s -X POST "http://eoapi.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{
    "collections": ["sentinel-2-iceland"],
    "bbox": [-22, 64, -18, 66],
    "datetime": "2023-06-01T00:00:00Z/2023-08-31T23:59:59Z",
    "limit": 5
  }' | jq '.features[] | {id, datetime: .properties.datetime}'
```{{exec}}

This searches for summer 2023 imagery over central Iceland.

### STAC API - Get a Specific Item

Let's retrieve details of a specific item:

```
ITEM_ID=$(curl -s "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items?limit=1" | jq -r '.features[0].id')
echo "Item ID: $ITEM_ID"
curl -s "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items/${ITEM_ID}" | jq '{id, datetime: .properties.datetime, cloud_cover: .properties["eo:cloud_cover"], assets: .assets | keys}'
```{{exec}}

### Raster API - Get Collection Information

Get information about the collection's mosaic, including available assets:

```
curl -s "http://eoapi.eoepca.local/raster/collections/sentinel-2-iceland/info" | jq
```{{exec}}

### Raster API - Generate a Tile URL

The Raster API can generate map tiles dynamically. Let's construct a tile URL for visualisation:

```
ITEM_ID=$(curl -s "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items?limit=1" | jq -r '.features[0].id')
echo "Preview URL for true colour composite:"
echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/preview?assets=visual"
```{{exec}}

### Vector API - Check Available Features

The Vector API provides OGC API Features access to database tables exposed by TiPG:

```
curl -s "http://eoapi.eoepca.local/vector/" | jq '.links[] | select(.rel=="data") | {title, href}'
```{{exec}}

### OGC API Maps - Check Synced Collections

The Maps Plugin synchronises STAC collections into an OGC API Maps catalogue every ten minutes. Trigger a sync now so the collection we just loaded is immediately available:

```
MAPS_SYNC_JOB=eoapi-maps-plugin-sync-manual
kubectl delete job "$MAPS_SYNC_JOB" -n data-access --ignore-not-found
kubectl create job "$MAPS_SYNC_JOB" \
  --from=cronjob/eoapi-maps-plugin-sync \
  --namespace data-access
kubectl wait --for=condition=complete job/"$MAPS_SYNC_JOB" \
  --namespace data-access \
  --timeout=180s
```{{exec}}

Now list the synchronised collections:

```
curl -s "http://eoapi.eoepca.local/maps/collections" |
  jq '.collections[] | {id, title}'
```{{exec}}


### STAC Manager UI

The STAC Manager provides a web interface for administering the catalogue. You can:
- Browse collections and items
- Edit metadata
- Create new collections (when transactions are enabled)

Access the STAC Manager from [this link]({{TRAFFIC_HOST1_82}}/manager/).

### Swagger Documentation

Each API provides interactive Swagger documentation:
- STAC API: `{{TRAFFIC_HOST1_82}}/stac/api.html`
- Raster API: `{{TRAFFIC_HOST1_82}}/raster/api.html`
- Vector API: `{{TRAFFIC_HOST1_82}}/vector/api.html`
- OGC API Maps: `{{TRAFFIC_HOST1_82}}/maps/openapi?f=html`

You can access the STAC API documentation from [this link]({{TRAFFIC_HOST1_82}}/stac/api.html).
