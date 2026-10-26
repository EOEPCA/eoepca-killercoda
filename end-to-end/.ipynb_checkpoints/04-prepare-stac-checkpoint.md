# Adapt STAC metadata to Best Practices

The data is pulled from the external catalogue (Step 1). Now it must be reshaped so the resulting collection and items conform to STAC Best Practices before registration.

Activate the Python environment:

```
source ~/datacube-venv/bin/activate
```

## Prepare STAC metadata

```
python - <<'PY'
import json, os

# Load the DLR-queried items.
items = json.load(open("/tmp/stac-items.json"))

# Set a name for the catalog and collection (needed for intermediate local saving).
# IMPORTANT: added user prefix for the local private STAC API.
catalog_id = "eoepcauser.s5p-cf-bp-stac-catalog"
collection_id = "eoepcauser.s5p-cf-bp"

# bbox (European region)
bbox = [-10.0, 35.0, 30.0, 70.0]

# Catalog extensions to use.
stac_extensions_catalog = []

# Initialize catalog.
catalog = pystac.Catalog(
    id=catalog_id,
    description="Root catalog for S5P Cloud Fraction.",
    title="S5P Cloud Fraction STAC Catalog",
    stac_extensions=stac_extensions_catalog,
)

# Collection extensions to use.
stac_extensions_collection = [
    "https://stac-extensions.github.io/item-assets/v1.0.0/schema.json",
    "https://stac-extensions.github.io/eo/v1.1.0/schema.json",
    "https://stac-extensions.github.io/projection/v2.0.0/schema.json",
    "https://stac-extensions.github.io/raster/v1.1.0/schema.json",
    # "https://stac-extensions.github.io/datacube/v2.3.0/schema.json", # datacube schema does not allow validation on collection level
    # "https://stac-extensions.github.io/storage/v2.0.0/schema.json"  # pending OpenEO inclusion
]

# Footprint from the "new" bbox (as used in the STAC search).
footprint = Polygon([
    [bbox[0], bbox[1]],
    [bbox[0], bbox[3]],
    [bbox[2], bbox[3]],
    [bbox[2], bbox[1]],
])
footprint = mapping(footprint)

# Shape/transform for the proj extension (must come from the loaded data).
shape = [ds.sizes["latitude"], ds.sizes["longitude"]]
transform = list(ds.cf.rio.transform())
proj_epsg = int(items[0].properties.get("proj:code").split(":")[1])

# Time extent from returned items.
datetimes = [item.datetime for item in items if item.datetime is not None]
start_time, end_time = min(datetimes), max(datetimes)
temporal_extent = [(start_time.isoformat(), end_time.isoformat())]
now_time = datetime.now(timezone.utc).isoformat()

print(f"catalog_id   = {catalog_id}")
print(f"collection_id = {collection_id}")
print(f"proj_epsg    = {proj_epsg}")
PY
```

{{exec}}

### Build the Collection

```
python - <<'PY'
collection = Collection(
    id=collection_id,
    title="Sentinel-5P Cloud Fraction",
    description="Sentinel-5P Cloud Fraction L3 data (Aug-Dec 2023)",
    stac_extensions=stac_extensions_collection,
    license="CC-BY-4.0",
    extent=Extent(
        spatial=SpatialExtent(bbox),
        temporal=TemporalExtent(intervals=[start_time, end_time]),
    ),
)
collection.extra_fields["created"] = now_time

collection.add_asset(
    "thumbnail",
    Asset(
        href="https://geoservice.dlr.de/catalogue/srv/api/records/587a076a-0cb6-494b-8f87-3fc8cfea8b22/attachments/atmosphere-S5P_TROPOMI_L3_P1D_CF_ql_s.jpg",
        media_type="image/png",
        title="Cloud Fraction Thumbnail",
        roles=["thumbnail"],
    ),
)

collection.summaries = Summaries(summaries={
    "datetime": {"min": start_time.isoformat(), "max": end_time.isoformat()},
    "bands": [{"name": "cf", "description": "Radiometric cloud fraction (Sentinel-5P)", "eo:common_name": "cloud_fraction"}],
    "platform": [items[0].properties.get("platform")],
    "constellation": [items[0].properties.get("constellation")],
    "instruments": [items[0].properties.get("instruments")],
    "eo:cloud_cover": [items[0].properties.get("eo:cloud_cover")],
    "proj:code": [items[0].properties.get("proj:code")],
    "proj:transform": transform,
})
collection.extra_fields["item_assets"] = {
    "cf": {
        "type": "image/tiff; application=geotiff",
        "title": "Cloud Fraction",
        "description": "Radiometric cloud fraction (Sentinel-5P)",
        "roles": ["data"],
    }
}

datacube_ext = {"cube:dimensions": {
    "x": {"type": "spatial", "axis": "x", "extent": [bbox[0], bbox[2]], "reference_system": proj_epsg},
    "y": {"type": "spatial", "axis": "y", "extent": [bbox[1], bbox[3]], "reference_system": proj_epsg},
    "time": {"type": "temporal", "extent": temporal_extent, "step": "P5D"},
    "band": {"type": "bands", "values": ["cf"]},
}}
collection.extra_fields.update(datacube_ext)
json.dump(collection.to_dict(), open("/tmp/stac-collection.json", "w"))
print(collection)
PY
```

{{exec}}

### Build the Items

```
python - <<'PY'
stac_extensions_item = [
    "https://stac-extensions.github.io/eo/v1.1.0/schema.json",
    "https://stac-extensions.github.io/projection/v2.0.0/schema.json",
    "https://stac-extensions.github.io/raster/v1.1.0/schema.json",
    "https://stac-extensions.github.io/storage/v2.0.0/schema.json",
    "https://stac-extensions.github.io/sentinel-5p/v0.2.0/schema.json",
]

new_items = []
for old_item in items:
    new_item = Item(
        id=old_item.id,
        geometry=footprint,
        bbox=bbox,
        datetime=old_item.datetime,
        properties=dict(old_item.properties),
    )

    # adapt proj info on properties level to match actual extents
    new_item.properties["proj:bbox"] = bbox
    new_item.properties["proj:shape"] = shape

    # adapt assets
    for key, asset in old_item.assets.items():
        if key == "cf":
            new_asset = Asset(
                href=asset.href,
                media_type=asset.media_type,
                roles=asset.roles,
                title=asset.title,
                description=asset.description,
                extra_fields={
                    "bands": [
                        {"name": "cf", "description": "Radiometric cloud fraction (Sentinel-5P)", "eo:common_name": "cloud_fraction"}
                    ]
                },
            )
            new_item.add_asset("cf", new_asset)

            proj = ProjectionExtension.ext(new_asset, add_if_missing=True)
            proj.code = asset.extra_fields.get("proj:code", "")
            proj.shape = shape
            proj.transform = transform

    # normalize other properties
    if new_item.properties.get("license") == "CC-BY 4.0":
        new_item.properties["license"] = "CC-BY-4.0"
    if isinstance(new_item.properties.get("instruments"), str):
        new_item.properties["instruments"] = [new_item.properties["instruments"]]

    new_item.properties["updated"] = now_time
    collection.add_item(new_item)
    new_items.append(new_item)

json.dump(new_items[0].to_dict(), open("/tmp/stac-items.json", "w"))
print(f"Created {len(new_items)} items. First item updated.")
PY
```

{{exec}}

### Save Catalog to disk

```
python - <<'PY'
import os
os.makedirs(catalog_id, exist_ok=True)
catalog.add_child(collection)
catalog.normalize_and_save(root_href=catalog_id, catalog_type=pystac.CatalogType.SELF_CONTAINED)
print(f"Catalog saved to: {catalog_id}")
print(f"Number of items: {len(list(collection.get_all_items()))}")
PY
```

{{exec}}

## Validate the saved catalog

Validate the collection and each item before uploading.

```
python - <<'PY'
catalog = pystac.read_file(f"{catalog_id}/catalog.json")
print(f"Validating catalog: {catalog.validate()}")
collection = catalog.get_child(collection_id)
print(f"Validating collection: {collection.validate()}")

items = list(collection.get_all_items())
for item in items:
    try:
        item.validate()
    except Exception as e:
        print(f"Failed items {item.id}: {e}")
PY
```

{{exec}}

**Checkpoint:** STAC metadata is prepared, adapted to Best Practices and validated. In the next scenario [Save metadata to the EOEPCA Workspace](./05-workspace.md) you will store this catalog.