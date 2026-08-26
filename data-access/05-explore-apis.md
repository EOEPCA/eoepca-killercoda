
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

### Raster API - TiTiler Map Viewer

TiTiler has a built-in map viewer which uses the tiles API above:

```
echo "Map viewer URL true colour composite:"
echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/WebMercatorQuad/map.html?tilesize=256&filter-lang=cql2-text&assets=visual&pixel_selection=first"
```{{exec}}

### Vector API - Discover Feature Endpoints

The Vector API provides OGC API Features access to PostgreSQL tables exposed by
TiPG. This tutorial does not load a separate vector dataset, but we can inspect
the links that advertise its collection and feature endpoints:

```
curl -s "http://eoapi.eoepca.local/vector/" | jq '.links[] | select(.rel=="data") | {title, href}'
```{{exec}}

### Multidimensional API - Inspect Available Operations

The Multidimensional API uses TiTiler and xarray to access formats such as Zarr
and NetCDF. This tutorial does not load a multidimensional dataset, but its
OpenAPI document confirms the service is available and shows how many operations
it exposes:

```
curl -fsS "http://eoapi.eoepca.local/multidim/api" |
  jq '{title: .info.title, version: .info.version, endpoints: (.paths | keys | length)}'
```{{exec}}

### STAC Manager UI

The STAC Manager provides a web interface for administering the catalogue. You can:
- Browse collections and items
- Edit metadata
- Create new collections (when transactions are enabled)

Access the STAC Manager from [this link]({{TRAFFIC_HOST1_82}}/manager/).

### Swagger Documentation

Each API provides interactive Swagger documentation:
- [STAC API]({{TRAFFIC_HOST1_82}}/stac/api.html)
- [Raster API]({{TRAFFIC_HOST1_82}}/raster/api.html)
- [Vector API]({{TRAFFIC_HOST1_82}}/vector/api.html)
- [Multidimensional API]({{TRAFFIC_HOST1_82}}/multidim/api.html)
- [OpenEO]({{TRAFFIC_HOST1_82}}/openeo/api.html)
