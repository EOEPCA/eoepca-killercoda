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
    "datetime": "2023-06-01T00:00:00Z/2023-08-31T23:59:59Z",
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
source ~/.eoepca/state
EOAPI_PROXY_PORT=$(
  awk -v host="$INGRESS_HOST" '$0 ~ ("eoapi." host) {print $1; exit}' \
    /tmp/assets/killercodaproxy
)
EOAPI_PUBLIC_URL=$(
  sed "s/PORT/${EOAPI_PROXY_PORT}/" /etc/killercoda/host
)

curl -s "http://eoapi.eoepca.local/raster/collections/sentinel-2-iceland/WebMercatorQuad/tilejson.json?assets=visual" |
  jq --arg base "${EOAPI_PUBLIC_URL}/raster" '
    .tiles |= map(sub("^https?://[^/]+"; $base))
    | {name, bounds, minzoom, maxzoom, tiles}
  '
```{{exec}}

The command rewrites the service's internal tile hostname and adds the `/raster` ingress prefix. The resulting `tiles` URL can be used from your workstation in QGIS or web mapping libraries such as Leaflet and OpenLayers.

> The first uncached mosaic tile can take a minute or more to render while the
> source imagery is fetched. If the Localcoda proxy times out on that first
> request, retry the tile once it has warmed the raster cache.

---

### Using the STAC Browser

The deployment includes a built-in STAC Browser for visual exploration:

1. Open the [Iceland collection]({{TRAFFIC_HOST1_82}}/browser/external/{{TRAFFIC_HOST1_82}}/stac/collections/sentinel-2-iceland)
2. Browse the available items
3. Open an item to inspect its footprint and assets
4. Each item shows a thumbnail and metadata
5. Click on asset links to view or download data
