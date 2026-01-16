
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
echo "http://eoapi.eoepca.local/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/preview?assets=visual"
```{{exec}}

### Vector API - Check Available Features

The Vector API provides OGC API Features access:

```
curl -s "http://eoapi.eoepca.local/vector/" | jq '.links[] | select(.rel=="data") | {title, href}'
```{{exec}}

### Health Checks

All services provide health check endpoints:

```
echo "Checking service health..."
echo -n "STAC API: "; curl -s -o /dev/null -w "%{http_code}" "http://eoapi.eoepca.local/stac/_mgmt/ping"
echo ""
echo -n "Raster API: "; curl -s -o /dev/null -w "%{http_code}" "http://eoapi.eoepca.local/raster/healthz"
echo ""
echo -n "Vector API: "; curl -s -o /dev/null -w "%{http_code}" "http://eoapi.eoepca.local/vector/healthz"
echo ""
```{{exec}}

### STAC Manager UI

The STAC Manager provides a web interface for administering the catalogue. You can:
- Browse collections and items
- Edit metadata
- Create new collections (when transactions are enabled)

Access the STAC Manager from [this link]({{TRAFFIC_HOST1_80}}/manager/).

### Swagger Documentation

Each API provides interactive Swagger documentation:
- STAC API: `http://eoapi.eoepca.local/stac/api.html`
- Raster API: `http://eoapi.eoepca.local/raster/api.html`
- Vector API: `http://eoapi.eoepca.local/vector/api.html`

You can access the STAC API documentation from [this link]({{TRAFFIC_HOST1_80}}/stac/api.html).