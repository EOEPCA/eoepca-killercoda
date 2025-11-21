## Using the openEO Python Client

### Install Dependencies

```bash
apt update
apt install -y python3.12-venv
python3 -m venv venv
source venv/bin/activate
pip install openeo xarray netCDF4 h5netcdf
```{{exec}}

### Start Python Session

```bash
python3
```{{exec}}

Import libraries:

```python
import openeo
import json
import os
import xarray
```{{exec}}

Connect and authenticate:

```python
openeo_url = os.environ.get('OPENEO_URL', 'http://openeo.eoepca.local')
connection = openeo.connect(openeo_url)
connection.authenticate_basic("testuser", "testuser123")

collection_id = "TestCollection-LonLat16x16"
temporal_extent = "2024-09"
spatial_extent = {"west": 3, "south": 51, "east": 5, "north": 53}
```{{exec}}

### Quick Discovery

```python
print(f"Collections: {connection.list_collection_ids()}")
print(f"Process count: {len(connection.list_processes())}")
```{{exec}}

### Execute Simple Process

```python
result = connection.execute({
    "add": {
        "process_id": "add",
        "arguments": {"x": 3, "y": 5},
        "result": True,
    }
})
print(f"3 + 5 = {result}")
```{{exec}}

### Load and Download Data

```python
cube_original = connection.load_collection(
    collection_id=collection_id,
    temporal_extent=temporal_extent,
    spatial_extent=spatial_extent,
    bands=["Longitude", "Latitude", "Day"],
)
cube_original.download("original.nc")
ds = xarray.load_dataset("original.nc")
print(ds)
```{{exec}}

### Build Complex Processing Chain

```python
cube_processed = connection.load_collection(
    collection_id=collection_id,
    temporal_extent=["2024-09-01", "2024-09-30"],
    spatial_extent=spatial_extent
)

cube_processed = cube_processed.filter_temporal(["2024-09-10", "2024-09-20"])
cube_processed = cube_processed.reduce_dimension(dimension="t", reducer="max")
cube_processed = cube_processed.apply(lambda x: x * 100)

graph = json.loads(cube_processed.to_json())
print(f"Processing chain: {' → '.join(graph['process_graph'].keys())}")
```{{exec}}

### Save and Validate Process Graph

```python
with open("workflow.json", "w") as f:
    json.dump(graph, f, indent=2)

connection.validate_process_graph(graph)
print("✓ Graph validated and saved")
```{{exec}}

### Band Mathematics

```python
cube_bands = connection.load_collection(
    collection_id=collection_id,
    temporal_extent="2024-09",
    spatial_extent=spatial_extent,
    bands=["Longitude", "Latitude"]
)

# Calculate: (Longitude + Latitude) / 2
lon = cube_bands.band("Longitude")
lat = cube_bands.band("Latitude")
average = (lon + lat) / 2

cube_bands.download("bands.nc")
average.download("average.nc")

# download average graph
average_graph = json.loads(average.to_json())
with open("average_workflow.json", "w") as f:
    json.dump(average_graph, f, indent=2)
```{{exec}}

### Verify Band Calculation

```python
ds_bands = xarray.load_dataset("bands.nc")
ds_avg = xarray.load_dataset("average.nc")

# Sample first pixel
lon_val = ds_bands.Longitude.values[0, 0, 0]
lat_val = ds_bands.Latitude.values[0, 0, 0]
expected = (lon_val + lat_val) / 2
actual = ds_avg['var'].values[0, 0, 0]

print(f"Longitude: {lon_val:.2f}, Latitude: {lat_val:.2f}")
print(f"Expected average: {expected:.2f}, Actual: {actual:.2f}")
print(f"✓ Calculation correct" if abs(expected - actual) < 0.001 else "✗ Mismatch")
```{{exec}}

### Exit

```python
exit()
```{{exec}}

```bash
ls -lh *.nc *.json
deactivate
```{{exec}}