EODAG provides a powerful Python API for integration into your applications.

### Start Python

First activate the virtual environment and start Python:

```
source ~/venv/bin/activate
python3
```{{exec}}

### Initialise EODAG

```python
from eodag import EODataAccessGateway
dag = EODataAccessGateway()
```{{exec}}

### List Available Providers

```python
providers = dag.available_providers()
print(f"Found {len(providers)} providers")
print(providers[:10])
```{{exec}}

### Search for Sentinel-2 Products

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

### Inspect a Product

```python
product = results[0]
print(f"ID: {product.properties.get('id')}")
print(f"Date: {product.properties.get('startTimeFromAscendingNode')}")
print(f"Cloud cover: {product.properties.get('cloudCover'):.1f}%")
print(f"Provider: {product.provider}")
```{{exec}}

### View Product as GeoJSON

```python
geojson = product.as_dict()
print(f"Type: {geojson.get('type')}")
print(f"Geometry: {geojson.get('geometry', {}).get('type')}")
print(f"Assets: {len(geojson.get('assets', {}))}")
```{{exec}}

### List Available Properties

```python
print(list(product.properties.keys()))
```{{exec}}

### Search with a WKT Polygon

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

```python
product_types = dag.list_product_types(provider="earth_search")
for pt in product_types[:5]:
    print(f"- {pt.get('ID')}: {pt.get('title', 'No title')}")

```{{exec}}

### Exit Python

```python
exit()
```{{exec}}
