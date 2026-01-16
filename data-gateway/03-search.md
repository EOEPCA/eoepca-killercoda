
Now let's search for EO products using the EODAG CLI.

### Basic Search

Search for Sentinel-2 Level-1C products over a specific area and time range:

```
eodag search \
  --productType S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-01-01 \
  --end 2024-01-15
```{{exec}}

The parameters are:
- `--productType`: The collection/product type to search
- `--box`: Bounding box as `min_lon min_lat max_lon max_lat`
- `--start` / `--end`: Temporal range
- `--provider`: Specific provider to query (optional)

### View Search Results

The search results are saved to `search_results.geojson` by default. Let's examine them:

```
cat search_results.geojson | python3 -m json.tool | head -80
```{{exec}}

Count the number of products found:

```
cat search_results.geojson | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'Found {len(d[\"features\"])} products')"
```{{exec}}

### Search with Cloud Cover Filter

Filter products by maximum cloud cover percentage:

```
eodag search \
  --productType S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-06-01 \
  --end 2024-06-30 \
  --cloudCover 20 \
  --storage low_cloud_results.geojson
```{{exec}}

```
cat low_cloud_results.geojson | python3 -c "import json,sys; d=json.load(sys.stdin); print(f'Found {len(d[\"features\"])} products with <=20% cloud cover')"
```{{exec}}

### Search for Landsat Products

Search for Landsat-8 products from USGS:

```
eodag search \
  --productType LANDSAT_C2L1 \
  --box -122.5 37.5 -122 38 \
  --start 2024-01-01 \
  --end 2024-03-31 \
  --storage landsat_results.geojson
```{{exec}}

### Get All Results

By default, search returns the first page. To get all matching products:

```
eodag search \
  --productType S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-01-01 \
  --end 2024-01-05 \
  --all \
  --storage all_results.geojson
```{{exec}}

### Verbose Output

Add verbosity to see what EODAG is doing:

```
eodag -vv search \
  --productType S2_MSI_L1C \
  --box 1 43 2 44 \
  --start 2024-01-01 \
  --end 2024-01-02 \
  --storage verbose_results.geojson
```{{exec}}