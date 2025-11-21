
OpenEO works with Earth Observation data collections. Let's explore how to load and work with collections.

First, let's create a sample data collection configuration for our backend (in production, this would connect to real STAC catalogs):

```bash
cat <<'EOF' > sample_collection.py
import openeo
import numpy as np
from datetime import datetime, timedelta

# Connect to backend
connection = openeo.connect("http://openeo.eoepca.local")

# In a real scenario, you would load from a STAC catalog
# For demo, we'll use synthetic data
print("Available collections:")
collections = connection.list_collections()
for coll in collections:
    print(f"  {coll['id']}")

# If Sentinel-2 is available, let's explore it
if any(c['id'] == 'sentinel-2-l2a' for c in collections):
    s2_collection = connection.describe_collection("sentinel-2-l2a")
    print("\nSentinel-2 L2A Collection metadata:")
    print(f"  Temporal extent: {s2_collection.get('extent', {}).get('temporal', {})}")
    print(f"  Spatial extent: {s2_collection.get('extent', {}).get('spatial', {})}")
    print(f"  Bands: {[b['name'] for b in s2_collection.get('cube:dimensions', {}).get('bands', {}).get('values', [])]}")
EOF
```

Run the collection exploration:

```bash
python sample_collection.py
```

Now let's create a script that demonstrates loading a collection with filters:

```bash
cat <<'EOF' > load_data.py
import openeo
from datetime import date

connection = openeo.connect("http://openeo.eoepca.local")

# Define area of interest (example: a small area in Europe)
west, south, east, north = 11.0, 46.0, 12.0, 47.0

# Load collection with spatial and temporal filters
datacube = connection.load_collection(
    "sentinel-2-l2a",  # or another available collection
    spatial_extent={"west": west, "south": south, "east": east, "north": north},
    temporal_extent=["2023-06-01", "2023-06-30"],
    bands=["B04", "B03", "B02"]  # RGB bands
)

print("Datacube loaded successfully!")
print(f"Process graph: {datacube.to_json()}")
EOF
```

This demonstrates the key OpenEO concept of building a process graph that describes the processing chain without immediately executing it.