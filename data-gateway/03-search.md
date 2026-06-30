Now we will turn the product-type definitions into catalogue searches. EODAG translates the common spatial, temporal, and product filters into the selected provider's native API and writes normalised GeoJSON results.

### Basic Search

Search for up to five Sentinel-2 Level-1C products over a one-degree bounding box in southern France:

```
eodag search \
  --productType S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-01-01 \
  --end 2024-01-15 \
  --items 5 \
  --storage sentinel2_results.geojson
```{{exec}}

The parameters are:

- `--productType`: The collection/product type to search
- `--box`: Bounding box as `min_lon min_lat max_lon max_lat`
- `--start` / `--end`: Temporal range
- `--items`: Maximum number of products requested for this page
- `--storage`: Output GeoJSON file

The EODAG 3.10 CLI does not have a provider option for `search`. It tries compatible providers in priority order and falls back when one is unavailable. The Python and STAC examples later show how to select `earth_search` explicitly.

### Inspect the Normalised Results

Instead of printing the entire GeoJSON document, summarise the collection and its first product:

```
jq '{
  type,
  returned: (.features | length),
  first_product: (
    .features[0] | {
      id,
      provider: .properties.eodag_provider,
      datetime: .properties.startTimeFromAscendingNode,
      cloud_cover: .properties.cloudCover
    }
  )
}' sentinel2_results.geojson
```{{exec}}

`eodag_provider` records which backend answered the request. Other fields have been mapped into EODAG's common metadata model, so downstream code does not need to understand the provider's original response format.

### Search with Cloud Cover Filter

Optical scenes are commonly filtered by cloud cover. Add a maximum of 20 percent and again request no more than five products:

```
eodag search \
  --productType S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-06-01 \
  --end 2024-06-30 \
  --cloudCover 20 \
  --items 5 \
  --storage low_cloud_results.geojson
```{{exec}}

```
jq -r '
  "Returned \(.features | length) products; cloud cover values: "
  + ([.features[].properties.cloudCover] | join(", "))
' low_cloud_results.geojson
```{{exec}}

This is a catalogue metadata filter. It does not inspect image pixels, and cloud-cover definitions can vary between collections.

### Search for Landsat Products

The same interface works for a different mission. Search for Landsat Collection 2 Level-1 products over the San Francisco Bay area:

```
eodag search \
  --productType LANDSAT_C2L1 \
  --box -122.5 37.5 -122 38 \
  --start 2024-01-01 \
  --end 2024-03-31 \
  --items 5 \
  --storage landsat_results.geojson
```{{exec}}

Confirm the result count and the provider selected by EODAG:

```
jq '{
  returned: (.features | length),
  provider: .features[0].properties.eodag_provider,
  first_id: .features[0].id
}' landsat_results.geojson
```{{exec}}

This illustrates the gateway idea: the query structure and output format remain the same even though the mission and upstream catalogue have changed.

### Get All Results

`--items` controls one result page. If a workflow genuinely needs every match, `--all` follows provider pagination until no more products remain. Use it carefully with broad areas or long date ranges.

This deliberately narrow query returns all matches without creating a large request:

```
eodag search \
  --productType S2_MSI_L1C \
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

Verbose logs reveal the provider-selection process. The `grep` keeps the workshop output focused on provider attempts and the final result:

```
eodag -vv search \
  --productType S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-01-01 \
  --end 2024-01-05 \
  --storage verbose_results.geojson \
  2>&1 |
  grep --color=never -E \
    'Searching on provider|No result could|Returned|Results stored'
```{{exec}}

It is normal to see one public endpoint fail before EODAG falls back to another. That is different from an empty successful search: the log tells us whether a provider returned no matching products or could not answer the request.
