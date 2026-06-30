The Python API exposes the same gateway model directly to application code. This is the interface a processing service or notebook would normally use when search results need to feed into further logic.

### Start Python

Activate the virtual environment again and start an interactive Python session:

```
source ~/venv/bin/activate
python3
```{{exec}}

### Initialise EODAG

Create the gateway object. During initialisation EODAG loads the built-in provider definitions, then merges any overrides and credentials from `~/.config/eodag/eodag.yml`.

```python
from eodag import EODataAccessGateway
dag = EODataAccessGateway()
```{{exec}}

### List Available Providers

`available_providers()` reports the providers that remain usable with the current configuration. Providers that require missing search credentials are excluded.

```python
providers = dag.available_providers()
print(f"Found {len(providers)} providers")
print(providers[:10])
```{{exec}}

### Search for Sentinel-2 Products

The Python API can select a provider explicitly. This request asks Earth Search for at most five Sentinel-2 Level-1C products intersecting the bounding box:

```python
results = dag.search(
    productType="S2_MSI_L1C",
    geom={"lonmin": 1, "latmin": 43, "lonmax": 2, "latmax": 44},
    start="2024-01-01",
    end="2024-01-10",
    provider="earth_search",
    items_per_page=5
)
print(f"Found {len(results)} products")
```{{exec}}

`results` behaves like a Python list of normalised EODAG product objects. `items_per_page=5` limits this request; it is not a count of every possible match.

### Inspect a Product

Select the first result and read commonly used metadata. EODAG maps provider-native field names into these common properties.

```python
product = results[0]
print(f"ID: {product.properties.get('id')}")
print(f"Date: {product.properties.get('startTimeFromAscendingNode')}")
print(f"Cloud cover: {product.properties.get('cloudCover'):.1f}%")
print(f"Provider: {product.provider}")
```{{exec}}

### View Product as GeoJSON

`as_dict()` serialises the product as a GeoJSON feature. For a STAC provider such as Earth Search, EODAG also preserves the product's asset descriptions.

```python
geojson = product.as_dict()
print(f"Type: {geojson.get('type')}")
print(f"Geometry: {geojson.get('geometry', {}).get('type')}")
print(f"Assets: {len(geojson.get('assets', {}))}")
```{{exec}}

### Inspect Data Assets

Print a few asset names and URLs. Sentinel-2 assets such as `B02`, `B03`, and `B04` represent individual spectral bands. We inspect the links rather than downloading the full scene.

```python
for name, asset in list(geojson.get("assets", {}).items())[:5]:
    print(f"{name}: {asset.get('href')}")
```{{exec}}

### Search with a WKT Polygon

The `geom` argument also accepts Well-Known Text (WKT), which is useful when geometry comes from a spatial database or another geospatial library:

```python
wkt = "POLYGON((1 43, 2 43, 2 44, 1 44, 1 43))"
results = dag.search(
    productType="S2_MSI_L1C",
    geom=wkt,
    start="2024-01-01",
    end="2024-01-05",
    provider="earth_search",
    items_per_page=3
)
for r in results:
    print(f"{r.properties.get('id')}: {r.properties.get('startTimeFromAscendingNode')}")
```{{exec}}

### Filter by Cloud Cover

Provider-specific queries are expressed with the same common arguments used by the CLI. This returns up to five products whose catalogue metadata reports no more than 20 percent cloud:

```python
results = dag.search(
    productType="S2_MSI_L1C",
    geom={"lonmin": 1, "latmin": 43, "lonmax": 2, "latmax": 44},
    start="2024-06-01",
    end="2024-06-30",
    provider="earth_search",
    cloudCover=20,
    items_per_page=5
)
print(f"Found {len(results)} products with <=20% cloud cover")
```{{exec}}

### List Product Types for a Provider

Applications can inspect provider capabilities before constructing a search:

```python
product_types = dag.list_product_types(provider="earth_search")
for pt in product_types[:5]:
    print(f"- {pt.get('ID')}: {pt.get('title', 'No title')}")
```{{exec}}

### Exit Python

Leave the interactive interpreter and return to the shell:

```python
exit()
```{{exec}}
