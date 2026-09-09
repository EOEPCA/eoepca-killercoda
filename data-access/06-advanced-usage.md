Use the same scene to compare spectral bands, then update the catalogue metadata.

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

This workflow uses STAC and raster services. Vector and multidimensional operations need suitable additional datasets. openEO processing uses the credentials generated during configuration.
