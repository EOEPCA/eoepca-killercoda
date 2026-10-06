Use the same scene to compare spectral bands, process it with openEO, then update the catalogue metadata.

### False-colour infrared

```bash
echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/preview?assets=nir&assets=red&assets=green&rescale=0,3000&rescale=0,3000&rescale=0,3000"
```{{exec}}

Open the URL. Near-infrared, red and green are mapped to the display's red, green and blue channels. Vegetation appears red; compare it with the true-colour preview.

### Short-wave infrared

```bash
echo "{{TRAFFIC_HOST1_82}}/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/preview?assets=swir22&assets=swir16&assets=red&rescale=0,4000&rescale=0,4000&rescale=0,3000"
```{{exec}}

This combination shows land and water differently, helping distinguish surface materials. The `rescale` parameters stretch each band's values to display brightness. These are visual comparisons, not a calibrated classification.

### Process the scene with openEO

titiler-openeo serves the same catalogue through the openEO API. Without IAM it uses the basic-auth credentials generated during configuration. Exchange them for an access token and list the collections openEO can see:

```bash
source ~/.eoepca/state
OPENEO_TOKEN=$(curl -fsS -u "${OPENEO_BASIC_AUTH_USER}:${OPENEO_BASIC_AUTH_PASSWORD}" \
  "http://eoapi.eoepca.local/openeo/credentials/basic" | jq -r '.access_token')

curl -fsS -H "Authorization: Bearer basic//${OPENEO_TOKEN}" \
  "http://eoapi.eoepca.local/openeo/collections" | jq
```{{exec}}

`sentinel-2-iceland` is listed. Its `cube:dimensions` show how openEO treats the collection: a data cube with `x`, `y`, time (`t`) and band (`spectral`) dimensions.

An openEO process graph describes processing as connected steps. This one loads the true-colour band on the date of the scene you found, reduces the time dimension with `first` to keep one value per pixel, and returns a PNG. Publish it as an XYZ map tile service:

```bash
cat > true-colour-service.json <<'EOF'
{
  "title": "Sentinel-2 Iceland true colour",
  "type": "XYZ",
  "enabled": true,
  "configuration": {"tile_size": 512},
  "process": {
    "process_graph": {
      "load": {
        "process_id": "load_collection",
        "arguments": {
          "id": "sentinel-2-iceland",
          "spatial_extent": {"from_parameter": "bounding_box"},
          "temporal_extent": ["2023-08-13", "2023-08-14"],
          "bands": ["visual"]
        }
      },
      "mosaic": {
        "process_id": "reduce_dimension",
        "arguments": {
          "data": {"from_node": "load"},
          "dimension": "t",
          "reducer": {
            "process_graph": {
              "first": {"process_id": "first", "arguments": {"data": {"from_parameter": "data"}}, "result": true}
            }
          }
        }
      },
      "save": {
        "process_id": "save_result",
        "arguments": {"data": {"from_node": "mosaic"}, "format": "PNG"},
        "result": true
      }
    }
  }
}
EOF

curl -fsS -X POST "http://eoapi.eoepca.local/openeo/services" \
  -H "Authorization: Bearer basic//${OPENEO_TOKEN}" \
  -H "Content-Type: application/json" \
  --data-binary @true-colour-service.json
```{{exec}}

The service is created without printing a response. List your services; the `url` is a `{z}/{x}/{y}` tile template for map clients:

```bash
curl -fsS -H "Authorization: Bearer basic//${OPENEO_TOKEN}" \
  "http://eoapi.eoepca.local/openeo/services" | jq

SERVICE_ID=$(curl -fsS -H "Authorization: Bearer basic//${OPENEO_TOKEN}" \
  "http://eoapi.eoepca.local/openeo/services" | jq -r '.services[0].id')
echo "{{TRAFFIC_HOST1_82}}/openeo/services/xyz/${SERVICE_ID}/tiles/8/112/67"
```{{exec}}

Open the printed URL to request one tile over west Iceland. titiler-openeo runs the process graph for the tile's area and returns the image; the white area is outside the satellite pass. Tile requests do not need the token, so the service can be shared with map clients.

### Update collection metadata

STAC transactions let you change catalogue records through the API. Download the collection and give it a workshop title:

```bash
curl -fsS "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland" -o collection.json
jq '.title = "Sentinel-2 Iceland workshop"' collection.json > collection-updated.json

curl -fsS -X PUT "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland" \
  -H "Content-Type: application/json" \
  --data-binary @collection-updated.json | jq
```{{exec}}

Read it back to confirm that the title was stored:

```bash
curl -fsS "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland" | jq
```{{exec}}

Refresh the [STAC Manager]({{TRAFFIC_HOST1_82}}/manager/) and [STAC Browser]({{TRAFFIC_HOST1_82}}/browser/). Both should display **Sentinel-2 Iceland workshop**. Open the collection in STAC Manager to inspect its description, extent and items. This deployment uses STAC Manager for browsing; the API transaction above performs the edit.

The items and imagery remain available. To restore the original metadata:

```bash
curl -fsS -X PUT "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland" \
  -H "Content-Type: application/json" \
  --data-binary @collection.json | jq
```{{exec}}

### Other interfaces

The deployed services also expose interactive API documentation:

- [STAC API]({{TRAFFIC_HOST1_82}}/stac/api.html)
- [Raster API]({{TRAFFIC_HOST1_82}}/raster/api.html)
- [Vector API]({{TRAFFIC_HOST1_82}}/vector/api.html)
- [Multidimensional API]({{TRAFFIC_HOST1_82}}/multidim/api.html)
- [openEO API]({{TRAFFIC_HOST1_82}}/openeo/api.html)

This workflow uses the STAC, Raster and openEO services. Vector and multidimensional operations need suitable additional datasets.
