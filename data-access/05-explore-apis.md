Find a clear summer scene over Reykjavík, then use its assets to render an image.

### Search by area, date and cloud cover

```bash
curl -fsS -X POST "http://eoapi.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{
    "collections": ["sentinel-2-iceland"],
    "bbox": [-22.5, 63.8, -21.5, 64.5],
    "datetime": "2023-06-01T00:00:00Z/2023-08-31T23:59:59Z",
    "query": {"eo:cloud_cover": {"lt": 10}},
    "sortby": [{"field": "properties.eo:cloud_cover", "direction": "asc"}],
    "limit": 1
  }' -o search.json
jq . search.json
```{{exec}}

The response contains the least cloudy matching scene. Inspect its acquisition time, `eo:cloud_cover`, footprint and `assets`. Cloud cover describes the whole scene, so some clouds may still appear over your area of interest.

Save its identifier for the following requests:

```bash
ITEM_ID=$(jq -r '.features[0].id' search.json)
echo "$ITEM_ID"
```{{exec}}

### Retrieve the item

```bash
curl -fsS "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items/${ITEM_ID}" | jq
```{{exec}}

The `visual` asset is a true-colour image. The `red`, `green`, `nir`, `swir16` and `swir22` assets hold individual bands for other combinations.

### Render a preview

```bash
curl -fsS --max-time 120 \
  "http://eoapi.eoepca.local/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/preview?assets=visual" \
  -o true-colour.png

echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/preview?assets=visual"
```{{exec}}

Open the printed URL. You should see Iceland's southwest coast, land and cloud in natural colours. The Raster API reads the source GeoTIFF and renders this preview on demand; the saved `true-colour.png` is the result.

### Explore the collection on a map

```bash
echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/WebMercatorQuad/map.html?tilesize=256&assets=visual&pixel_selection=first"
```{{exec}}

Open the map and zoom towards Reykjavík. The map requests tiles from a mosaic of the collection, so it can show different scenes from the single-item preview. The first tiles may take time to render while source imagery is read.

Inspect the tile service description:

```bash
curl -fsS "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/WebMercatorQuad/tilejson.json?assets=visual" | jq
```{{exec}}

The `tiles` entry is a URL template for map clients. The public tutorial proxy supplies browser-accessible links.
