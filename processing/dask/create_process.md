
Let's create a more complex process graph that demonstrates OpenEO's processing capabilities. We'll build a simple NDVI (Normalised Difference Vegetation Index) calculation:

```bash
cat <<'EOF' > create_ndvi_process.py
import openeo
import json

# Connect to the backend
connection = openeo.connect("http://openeo.eoepca.local")

# Define area of interest
bbox = {
    "west": 11.0,
    "south": 46.0, 
    "east": 11.5,
    "north": 46.5
}

# Load Sentinel-2 data
s2_cube = connection.load_collection(
    "sentinel-2-l2a",
    spatial_extent=bbox,
    temporal_extent=["2023-06-01", "2023-06-15"],
    bands=["B04", "B08"]  # Red and NIR bands for NDVI
)

# Calculate NDVI
red = s2_cube.band("B04")
nir = s2_cube.band("B08")
ndvi = (nir - red) / (nir + red)

# Reduce temporal dimension (calculate mean NDVI over time)
ndvi_mean = ndvi.reduce_dimension(
    dimension="t",
    reducer="mean"
)

# Save the process graph
process_graph = ndvi_mean.to_json()
with open("ndvi_process.json", "w") as f:
    json.dump(process_graph, f, indent=2)

print("NDVI process graph created!")
print(json.dumps(process_graph, indent=2))

# Validate the process graph
try:
    validation = connection.validate(ndvi_mean)
    print("\nProcess graph validation: PASSED")
except Exception as e:
    print(f"\nProcess graph validation failed: {e}")
EOF
```

Run the process creation:

```bash
python create_ndvi_process.py
```

Let's also create a more complex process that includes cloud masking:

```bash
cat <<'EOF' > advanced_process.py
import openeo

connection = openeo.connect("http://openeo.eoepca.local")

# Load data with cloud mask band
datacube = connection.load_collection(
    "sentinel-2-l2a",
    spatial_extent={"west": 11.0, "south": 46.0, "east": 11.5, "north": 46.5},
    temporal_extent=["2023-06-01", "2023-08-31"],
    bands=["B04", "B08", "SCL"]  # Include scene classification for cloud masking
)

# Apply cloud mask (SCL band values: 4=vegetation, 5=bare soil, exclude clouds)
cloud_mask = (datacube.band("SCL") == 4) | (datacube.band("SCL") == 5)
masked_cube = datacube.mask(cloud_mask)

# Calculate NDVI on cloud-free pixels
red = masked_cube.band("B04")
nir = masked_cube.band("B08")
ndvi = (nir - red) / (nir + red)

# Create temporal composite (median)
ndvi_composite = ndvi.reduce_dimension(
    dimension="t",
    reducer="median"
)

print("Advanced process graph with cloud masking created!")
print(f"Process nodes: {len(ndvi_composite.to_json()['process_graph'])}")
EOF
```

These examples show how OpenEO allows building complex Earth Observation processing chains in a standardised way.