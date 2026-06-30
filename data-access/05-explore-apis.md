
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

The sync updates the live Maps configuration, which can briefly restart its
worker. Retry the API for up to one minute, then list the synchronised
collections:

```
for attempt in {1..12}; do
  if curl -fsS "http://eoapi.eoepca.local/maps/collections" \
      -o /tmp/maps-collections.json &&
     jq -e '.collections | type == "array"' \
      /tmp/maps-collections.json >/dev/null; then
    break
  fi
  echo "Waiting for the Maps API to reload (${attempt}/12)..."
  sleep 5
done

jq '.collections[] | {id, title}' /tmp/maps-collections.json
```{{exec}}

Request a small map around Reykjavik and verify that the Maps API returns a PNG:

```
MAP_QUERY='f=png&bbox=-22.5,63.8,-21.5,64.5&width=256&height=256&transparent=true'

curl -fsS --max-time 60 \
  -o /tmp/reykjavik-map.png \
  -w 'Map response: HTTP %{http_code}, %{content_type}, %{size_download} bytes\n' \
  "http://eoapi.eoepca.local/maps/collections/sentinel-2-iceland/map?${MAP_QUERY}"

echo "{{TRAFFIC_HOST1_82}}/maps/collections/sentinel-2-iceland/map?${MAP_QUERY}"
```{{exec}}

The printed URL opens the generated map in your browser. Keeping the bounding
box focused avoids the much heavier request needed to render all of Iceland at
once.

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
- [OGC API Maps]({{TRAFFIC_HOST1_82}}/maps/openapi?f=html)
