
EODAG provides a powerful Python API for integration into your applications.

### Create a Python Script

Let's create a Python script that demonstrates the EODAG API:

```python
cat > /tmp/eodag_demo.py << 'EOF'
from eodag import EODataAccessGateway

# Initialise EODAG
dag = EODataAccessGateway()

# List available providers
print("=== Available Providers ===")
providers = dag.available_providers()
print(f"Found {len(providers)} providers")
print("First 10:", providers[:10])
print()

# Search for Sentinel-2 products
print("=== Searching for Sentinel-2 L1C Products ===")
search_results = dag.search(
    productType="S2_MSI_L1C",
    geom={"lonmin": 1, "latmin": 43, "lonmax": 2, "latmax": 44},
    start="2024-01-01",
    end="2024-01-10",
    provider="earth_search",
    items_per_page=5
)

print(f"Found {len(search_results)} products")
print()

# Display product details
print("=== Product Details ===")
for i, product in enumerate(search_results[:3]):
    print(f"\nProduct {i+1}:")
    print(f"  ID: {product.properties.get('id', 'N/A')}")
    # Try multiple datetime property names
    dt = product.properties.get('datetime') or product.properties.get('startTimeFromAscendingNode') or product.properties.get('start_datetime', 'N/A')
    print(f"  Date: {dt}")
    cloud = product.properties.get('cloudCover', 'N/A')
    if isinstance(cloud, (int, float)):
        print(f"  Cloud Cover: {cloud:.1f}%")
    else:
        print(f"  Cloud Cover: {cloud}")
    print(f"  Provider: {product.provider}")

# Get product as GeoJSON
if search_results:
    print("\n=== First Product as GeoJSON ===")
    geojson = search_results[0].as_dict()
    print(f"Type: {geojson.get('type')}")
    print(f"Geometry type: {geojson.get('geometry', {}).get('type')}")
    print(f"Number of assets: {len(geojson.get('assets', {}))}")
    
    # Show available property keys for debugging
    print(f"\n=== Available Properties ===")
    props = search_results[0].properties
    print("Property keys:", list(props.keys())[:15])
EOF
```{{exec}}

Run the script:

```
python3 /tmp/eodag_demo.py
```{{exec}}

### Add a Custom Provider

EODAG allows you to add custom STAC providers dynamically:

```python
cat > /tmp/eodag_custom_provider.py << 'EOF'
from eodag import EODataAccessGateway

dag = EODataAccessGateway()

# Add a custom STAC provider
dag.add_provider(
    "my_stac_catalog",
    search={
        "type": "StacSearch",
        "api_endpoint": "https://earth-search.aws.element84.com/v1/search",
    },
    products={
        "GENERIC_PRODUCT_TYPE": {
            "productType": "{productType}"
        }
    },
    download={
        "type": "HTTPDownload"
    }
)

print(f"Provider added: 'my_stac_catalog' in available providers: {'my_stac_catalog' in dag.available_providers()}")

# List product types for the new provider
print("\nDiscovering product types from custom provider...")
product_types = dag.list_product_types(provider="my_stac_catalog", fetch_providers=True)
print(f"Found {len(product_types)} product types")
if product_types:
    print("First 5 product types:")
    for pt in product_types[:5]:
        print(f"  - {pt.get('ID', pt.get('_id', 'Unknown'))}")
EOF
```{{exec}}

```
python3 /tmp/eodag_custom_provider.py
```{{exec}}

### Search with Geometry

Search using a WKT polygon:

```python
cat > /tmp/eodag_wkt.py << 'EOF'
from eodag import EODataAccessGateway

dag = EODataAccessGateway()

# Define search area as WKT
wkt_polygon = "POLYGON((1 43, 2 43, 2 44, 1 44, 1 43))"

results = dag.search(
    productType="S2_MSI_L1C",
    geom=wkt_polygon,
    start="2024-01-01",
    end="2024-01-05",
    provider="earth_search",
    items_per_page=3
)

print(f"Found {len(results)} products using WKT geometry")
for r in results:
    print(f"  - {r.properties.get('id', 'N/A')}: {r.properties.get('datetime', 'N/A')}")
EOF
```{{exec}}

```
python3 /tmp/eodag_wkt.py
```{{exec}}

### Integration with EOEPCA

In an EOEPCA deployment, the Data Gateway (EODAG) would typically be used by:

1. **Resource Registration Harvester**: To fetch metadata from external catalogues and register products locally
2. **Processing Engine**: To resolve data inputs and prepare them for workflow execution  
3. **Data Access Services**: To retrieve assets for visualisation

The unified interface means these components can work with any supported provider without implementing provider-specific logic.