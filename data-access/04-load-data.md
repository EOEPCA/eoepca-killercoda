
Now that the Data Access services are running, let's load some sample Earth Observation data.

### About the Sample Data

The deployment guide includes a sample Sentinel-2 Level-2A collection covering Iceland. This dataset contains:
- Multispectral imagery from Sentinel-2A and Sentinel-2B satellites
- 13 spectral bands at 10m, 20m, and 60m resolution
- Data from 2023 covering Iceland's extent

### Load the Collection

Navigate to the sample collection directory and run the ingestion script:

```
cd collections/sentinel-2-iceland
bash /tmp/assets/run-ingest-local
cd ../..
```{{exec}}


### Verify the Collection

Let's verify the collection was loaded successfully by querying the STAC API:

```
curl -s "http://eoapi.eoepca.local/stac/collections" | jq '.collections[].id'
```{{exec}}

You should see `sentinel-2-iceland` in the list.

### View Collection Details

Get the full collection metadata:

```
curl -s "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland" | jq '{id, title, description, extent}'
```{{exec}}

This shows the collection covers Iceland with a bounding box from approximately 24°W to 14°W longitude and 63°N to 67°N latitude.

### Count Items

Let's see how many items are in the collection:

```
curl -s "http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items?limit=1" | jq '.numberMatched'
```{{exec}}

The sample contains 226 items.

### Browse in STAC Browser

The eoAPI deployment includes a built-in STAC Browser that is already configured
to use this tutorial's STAC API. [Open the Iceland collection
directly]({{TRAFFIC_HOST1_82}}/browser/external/{{TRAFFIC_HOST1_82}}/stac/collections/sentinel-2-iceland) to browse
its items visually.
