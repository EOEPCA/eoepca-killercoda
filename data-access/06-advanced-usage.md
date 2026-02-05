Let's explore some more advanced capabilities of the Data Access APIs.

### Visualising Different Band Combinations

Sentinel-2 provides multiple spectral bands that can be combined for different analyses. First, let's get a good item to work with - we'll search for one covering Reykjavik to ensure we get actual land:

```bash
ITEM_ID=$(curl -s -X POST "http://eoapi.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{
    "collections": ["sentinel-2-iceland"],
    "bbox": [-22.5, 63.8, -21.5, 64.5],
    "query": {"eo:cloud_cover": {"lt": 20}},
    "limit": 1
  }' | jq -r '.features[0].id')
echo "Working with item: $ITEM_ID"
```{{exec}}

**True Colour (RGB)** - How the human eye would see it:

Construct the URL and click on the generated link in the terminal to view the image:
```bash
echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/preview?assets=visual"
```{{exec}}

**False Colour Infrared** - Highlights vegetation in red tones:
```bash
echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/preview?assets=nir&assets=red&assets=green&rescale=0,3000&rescale=0,3000&rescale=0,3000"
```{{exec}}

**SWIR Composite** - Useful for geology and soil moisture:
```bash
echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/preview?assets=swir22&assets=swir16&assets=red&rescale=0,4000&rescale=0,4000&rescale=0,3000"
```{{exec}}

> **Note:** The `rescale` parameters stretch the raw reflectance values to visible brightness. The `visual` asset is pre-rendered so doesn't need this.

---

### Finding Cloud-Free Imagery

For analysis, you often need the clearest images. Let's search for low cloud cover scenes over southwest Iceland:

```bash
curl -s -X POST "http://eoapi.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{
    "collections": ["sentinel-2-iceland"],
    "bbox": [-23, 63.5, -20, 65],
    "datetime": "2023-06-01T00:00:00Z/2023-08-31T23:59:59Z",
    "query": {"eo:cloud_cover": {"lt": 10}},
    "sortby": [{"field": "properties.eo:cloud_cover", "direction": "asc"}],
    "limit": 5
  }' | jq '.features[] | {id, date: .properties.datetime[:10], cloud_cover: .properties["eo:cloud_cover"]}'
```{{exec}}

Now preview the clearest one:
```bash
CLEAREST=$(curl -s -X POST "http://eoapi.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{
    "collections": ["sentinel-2-iceland"],
    "bbox": [-23, 63.5, -20, 65],
    "query": {"eo:cloud_cover": {"lt": 10}},
    "sortby": [{"field": "properties.eo:cloud_cover", "direction": "asc"}],
    "limit": 1
  }' | jq -r '.features[0].id')
echo "Clearest image: $CLEAREST"
echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/items/${CLEAREST}/preview?assets=visual"
```{{exec}}

---

### Working with Collection Mosaics

Instead of viewing individual items, you can access the entire collection as a seamless mosaic:

```bash
curl -s "http://eoapi.eoepca.local/raster/collections/sentinel-2-iceland/WebMercatorQuad/tilejson.json?assets=visual" | jq '{name: .name, bounds, minzoom, maxzoom}'
```{{exec}}

The tile URL from this TileJSON can be used in GIS applications like QGIS or web mapping libraries like Leaflet and OpenLayers.

---

### Using the STAC Browser

The deployment includes a built-in STAC Browser for visual exploration:

1. Open the [STAC Browser]({{TRAFFIC_HOST1_82}}/browser)
2. The root catalogue shows available collections
3. Click into `sentinel-2-iceland` to browse items
4. Each item shows a thumbnail and metadata
5. Click on asset links to view or download data