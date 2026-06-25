OpenEO users usually work through a client such as the [Python OpenEO Client](https://open-eo.github.io/openeo-python-client/) or the [OpenEO Web Editor](https://github.com/Open-EO/openeo-web-editor), rather than constructing HTTP requests manually.

Create a Python virtual environment and install the client and the libraries used to inspect downloaded NetCDF files:

```bash
cd ~
python3 -m venv openeo-test
source openeo-test/bin/activate
pip install --upgrade openeo xarray netCDF4
```{{exec}}

Start the Python interpreter:

```bash
python3
```{{exec}}

Import the required libraries:

```python
import openeo
import json
import xarray
```{{exec}}

Connect and authenticate with the demo account:

```python
connection = openeo.connect("http://openeo.eoepca.local")
connection.authenticate_basic("testuser", "testuser123")
```{{exec}}

Define the test collection and the subset used by the examples:

```python
collection_id = "TestCollection-LonLat16x16"
temporal_extent = "2024-09"
spatial_extent = {"west": 3, "south": 51, "east": 5, "north": 53}
```{{exec}}

We can now run the operations below.

### Discover Collections and Processes

```python
print(f"Collections: {connection.list_collection_ids()}")
print(f"Process count: {len(connection.list_processes())}")
```{{exec}}

### Execute a Simple Process

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

This is a synchronous processing request. It normally takes around 30 seconds in the workshop environment while the Spark executor performs the calculation.

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

### Build a Processing Chain

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

### Save and Validate the Process Graph

```python
with open("workflow.json", "w") as f:
    json.dump(graph, f, indent=2)

validation_errors = connection.validate_process_graph(graph)
if validation_errors:
    raise RuntimeError(validation_errors)

print("✓ Graph is valid and saved")
```{{exec}}

### Band Mathematics

The two downloads below are also synchronous and can each take around 30 seconds.

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
```{{exec}}

### Verify the Band Calculation

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

Exit Python, inspect the generated files, and deactivate the virtual environment:

```text
exit()
ls -lh *.nc *.json
deactivate
```{{exec}}

To build a process graph visually, open the [OpenEO Web Editor connected to this backend](https://editor.openeo.org/?server={{TRAFFIC_HOST1_81}}). Authenticate with username `testuser`{{copy}} and password `testuser123`{{copy}}, then use the **Processes** panel to reproduce the examples by connecting process nodes.
