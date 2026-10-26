# Query the external STAC catalogue

The data source for this exercise is the DLR GeoService STAC API. We will search for Sentinel-5P TROPOMI Level-3 cloud-fraction data covering Europe between August and December 2023.

Activate the Python environment:

```bash
source ~/datacube-venv/bin/activate
```

## Search the catalogue

Run the following query:

```bash
python - <<'PY'
import json
import certifi
from pystac_client import Client

# Use the CA certificates installed with the Python environment.
import os
os.environ["REQUESTS_CA_BUNDLE"] = certifi.where()
os.environ["CURL_CA_BUNDLE"] = certifi.where()

catalog_url = "https://geoservice.dlr.de/eoc/ogc/stac/v1/"
collection_id = "S5P_TROPOMI_L3_P1D_CF_v2"
bbox = [-10.0, 35.0, 30.0, 70.0]
date_range = "2023-08-01T00:00:00Z/2023-12-31T23:59:59Z"

catalog = Client.open(catalog_url)
search = catalog.search(
    collections=[collection_id],
    bbox=bbox,
    datetime=date_range,
    limit=400,
)

items = list(search.items())
print(f"Returned {len(items)} STAC items")

if not items:
    raise SystemExit("No items found; check the catalogue and query parameters.")

print("First item:", items[0].id)
print("Last item:", items[-1].id)

# Guess/adaptation: persist item metadata for the following tutorial steps.
with open("/tmp/cloud-fraction-items.json", "w") as f:
    json.dump([item.to_dict() for item in items], f, indent=2)

print("Saved item metadata to /tmp/cloud-fraction-items.json")
PY
```

{{exec}}

## Inspect the results

The search returns STAC Items: metadata records describing individual observations and their assets. The records can be inspected before attempting to load the underlying raster data.

```bash
python - <<'PY'
import json

with open("/tmp/cloud-fraction-items.json") as f:
    items = json.load(f)

item = items[0]
print("ID:", item["id"])
print("Datetime:", item.get("properties", {}).get("datetime"))
print("Assets:", list(item.get("assets", {}).keys()))
PY
```

{{exec}}

**Checkpoint:** confirm that the query returns items and that their metadata includes asset links. In the next step, we will prepare the metadata for registration in EOEPCA.

*Note:* the date range, bounding box, collection ID, and endpoint come from the source notebook. The temporary JSON export is an adaptation for this tutorial; it has not been tested in your Killercoda instance.

