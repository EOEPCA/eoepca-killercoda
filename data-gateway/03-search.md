Now we will turn the product-type definitions into catalogue searches. EODAG translates the common spatial, temporal, and product filters into the selected provider's native API and writes normalised GeoJSON results.

### Basic Search

Search for up to five Sentinel-2 Level-1C products over a one-degree bounding box in southern France:

```
eodag search \
  --collection S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-01-01 \
  --end 2024-01-15 \
  --limit 5 \
  --storage sentinel2_results.geojson
```{{exec}}

The parameters are:

- `--collection`: The collection to search
- `--box`: Bounding box as `min_lon min_lat max_lon max_lat`
- `--start` / `--end`: Temporal range
- `--limit`: Maximum number of products requested for this page
- `--storage`: Output GeoJSON file

### Inspect the Normalised Results

Instead of printing the entire GeoJSON document, summarise the collection and its first product:

```
jq '.features | length' sentinel2_results.geojson
jq '.features[0] | {id, provider: .properties."eodag:provider", datetime: .properties.start_datetime, cloud_cover: .properties."eo:cloud_cover"}' sentinel2_results.geojson
```{{exec}}

`eodag:provider` records which backend answered the request. Other fields have been mapped into EODAG's common metadata model, so downstream code does not need to understand the provider's original response format.

### Search with Cloud Cover Filter

Optical scenes are commonly filtered by cloud cover. Add a maximum of 20 percent and again request no more than five products:

```
eodag search \
  --collection S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-06-01 \
  --end 2024-06-30 \
  --cloud-cover 20 \
  --limit 5 \
  --storage low_cloud_results.geojson
```{{exec}}

```
jq '.features | length' low_cloud_results.geojson
jq '.features[].properties."eo:cloud_cover"' low_cloud_results.geojson
```{{exec}}

This is a catalogue metadata filter. It does not inspect image pixels, and cloud-cover definitions can vary between collections.

### Search for Landsat Products

The same interface works for a different mission. Search for Landsat Collection 2 Level-1 products over the San Francisco Bay area:

```
eodag search \
  --collection LANDSAT_C2L1 \
  --box -122.5 37.5 -122 38 \
  --start 2024-01-01 \
  --end 2024-03-31 \
  --limit 5 \
  --storage landsat_results.geojson
```{{exec}}

Confirm the result count and the provider selected by EODAG:

```
jq '.features | length' landsat_results.geojson
jq '.features[0].id, .features[0].properties."eodag:provider"' landsat_results.geojson
```{{exec}}

This illustrates the gateway idea: the query structure and output format remain the same even though the mission and upstream catalogue have changed.

### Get All Results

`--limit` controls one result page. If a workflow genuinely needs every match, `--all` follows provider pagination until no more products remain. Use it carefully with broad areas or long date ranges.

This deliberately narrow query returns all matches without creating a large request:

```
eodag search \
  --collection S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-01-01 \
  --end 2024-01-05 \
  --all \
  --storage all_results.geojson
```{{exec}}

```
jq '.features | length' all_results.geojson
```{{exec}}

### Observe Provider Fallback

The `-vv` flag turns on verbose logging, showing which provider EODAG picks and, if one fails or returns nothing, which provider it falls back to next:

```
eodag -vv search \
  --collection S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-01-01 \
  --end 2024-01-05 \
  --storage verbose_results.geojson
```{{exec}}

Look for the `Searching on provider` lines. It is normal to see one public endpoint fail before EODAG falls back to another. That is different from an empty successful search: the log tells us whether a provider returned no matching products or could not answer the request.
