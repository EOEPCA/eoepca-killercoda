Let's explore the Datacube Access API and understand how it filters collections based on datacube metadata.

### List Datacube Collections

The Datacube Access BB only exposes collections that have `cube:dimensions` or `cube:variables` defined:

```
curl -s "http://datacube-access.eoepca.local/collections" | jq '.collections[] | {id, title, has_datacube: (.["cube:dimensions"] != null)}'
```{{exec}}

### Get Collection Details

View the full datacube metadata for our collection:

```
curl -s "http://datacube-access.eoepca.local/collections/sentinel-2-datacube" | jq '{
  id,
  title,
  "cube:dimensions": .["cube:dimensions"],
  "cube:variables": .["cube:variables"]
}'
```{{exec}}

### Understanding the Datacube Metadata

The dimensions above map directly to how the data will be structured when loaded into xarray:
- `x` and `y` become spatial coordinates with reference system EPSG:32625
- `time` becomes the temporal dimension
- `bands` determines which data variables are available (B04, B08, SCL)

### Check Collection Links

The collection contains links to related endpoints:

```
curl -s "http://datacube-access.eoepca.local/collections/sentinel-2-datacube" | jq '.links[] | {rel, href}'
```{{exec}}

### Query Items via Resource Discovery

The Datacube Access BB filters collections but items are accessed via the underlying STAC catalog. Let's verify the items are available in Resource Discovery:

```
curl -s "http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-datacube/items" | jq '.features[] | {id, datetime: .properties.datetime, cloud_cover: .properties["eo:cloud_cover"]}'
```{{exec}}

### Compare Collections

The key purpose of Datacube Access is filtering. Compare Resource Discovery (all collections) with Datacube Access (datacube-ready only):

Resource Discovery:
```
curl -s "http://resource-catalogue.eoepca.local/stac/collections" | jq '[.collections[].id]'
```{{exec}}

Datacube Access:
```
curl -s "http://datacube-access.eoepca.local/collections" | jq '[.collections[].id]'
```{{exec}}

In a deployment with many collections, only those with `cube:dimensions` would appear in Datacube Access.

### Check Conformance

View the OGC conformance classes supported:

```
curl -s "http://datacube-access.eoepca.local/conformance" | jq '.conformsTo'
```{{exec}}

