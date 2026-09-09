Load the sample Sentinel-2 Level-2A collection supplied with the deployment guide. It contains 226 STAC items from 2023 covering Iceland. The metadata links to publicly accessible Cloud Optimised GeoTIFFs; ingestion does not copy those raster files into MinIO.

### Load the collection and items

```bash
cd collections/sentinel-2-iceland
../ingest.sh
cd ../..
```{{exec}}

The script loads the collection and its items into pgSTAC. You can run it again: existing records are left in place.

### Inspect the catalogue

```bash
curl -fsS "http://eoapi.eoepca.local/stac/collections" | jq
```{{exec}}

Look for `sentinel-2-iceland`. Its extent covers Iceland during 2023.

```bash
curl -fsS "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items?limit=1000&fields=id" | jq
```{{exec}}

`numberReturned` should be `226`. Each feature is an observation with its own identifier.

Open the [STAC Browser]({{TRAFFIC_HOST1_82}}/browser/) and select **Sentinel-2 Level-2A Iceland**. Browse an item to inspect its footprint, acquisition time and asset links.
