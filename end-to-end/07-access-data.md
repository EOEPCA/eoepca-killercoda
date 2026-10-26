# Access and process the registered data

Now the data is served by the EOEPCA STAC API. We query the registered collection and use odc-stac to load it into an xarray dataset, then build monthly cloud-fraction medians.

Activate the Python environment:

```
source ~/datacube-venv/bin/activate
```

## Query the registered collection

Query the EOEPCA STAC API with the same bounding box and date range as the external query, reusing the token from the previous step.

```
python - <<'PY'
import json, certifi, os
import requests

os.environ["REQUESTS_CA_BUNDLE"] = certifi.where()
os.environ["CURL_CA_BUNDLE"] = certifi.where()

auth = json.load(open("/tmp/stac-auth.json"))
stac_endpoint, collection_id, token = auth["stac_endpoint"], auth["collection_id"], auth["access_token"]

items = list(requests.get(
    f"{stac_endpoint}/collections/{collection_id}/items",
    headers={"Authorization": f"Bearer {token}"}, params={"limit": 400},
).json()["features"])
print(f"Query returned {len(items)} items from the EOEPCA STAC API")
json.dump(items, open("/tmp/registered-items.json", "w"), indent=2)
PY
```

{{exec}}

## Load and process the data

Load the registered items with odc-stac and compute a monthly median of the cloud fraction.

```
python - <<'PY'
import json
from odc.stac import stac_load

bbox = [-10.0, 35.0, 30.0, 70.0]
items = json.load(open("/tmp/registered-items.json"))

ds = stac_load(
    items,
    bands=["cf"],
    crs="EPSG:4326",
    resolution=0.1,
    bbox=bbox,
    chunks={"time": 1},
)
monthly_mean_cf = ds["cf"].groupby("time.month").median(dim="time")
print(monthly_mean_cf)
PY
```

{{exec}}

Plot the monthly cloud fractions to confirm the data is usable.

```
python - <<'PY'
monthly_mean_cf.plot(col="month", col_wrap=3, cmap="viridis",
                     vmin=0, vmax=1, figsize=(12, 6),
                     cbar_kwargs={"label": "Cloud Fraction"})
PY
```

{{exec}}

**Checkpoint:** the registered cloud-fraction data is loaded through the EOEPCA STAC API with odc-stac, reduced to monthly medians and visualised. This confirms the whole end-to-end workflow — external catalogue, STAC best practices, Workspace storage, STAC registration and data access — works together.