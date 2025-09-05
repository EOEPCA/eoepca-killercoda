Open EO users will not use the API directly, but mostly use the [Python OpenEO Client](https://open-eo.github.io/openeo-python-client/) or the [OpenEO Web Editor](https://github.com/Open-EO/openeo-web-editor).

If we want to use the [Python OpenEO Client](https://open-eo.github.io/openeo-python-client/), we can configure a python virtual environment and install it via

```
cd ~
python3 -m venv openeo-test
source openeo-test/bin/activate
pip install --upgrade openeo xarray netCDF4 h5netcdf
```{{exec}}

We can then run a basic processing from python. First we run python

```
python3
```{{exec}}

then we import Open client library abn all the other required libraries via

```
import openeo
import json
import os
import xarray
```{{exec}}

we connect to the OpenEO backend via

```python
connection = openeo.connect("http://openeo.eoepca.local")
connection.authenticate_basic("testuser","testuser123")
```{{exec}}

and define a test dataset via

```python
collection_id = "TestCollection-LonLat16x16"
temporal_extent = "2024-09"
spatial_extent = {"west": 3, "south": 51, "east": 5, "north": 53}
```{{exec}}

and we can run the basic operations below

Quick Collections and Processes Discovery:

```python
print(f"Collections: {connection.list_collection_ids()}")
print(f"Process count: {len(connection.list_processes())}")
```{{exec}}

Execute Simple Process:

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

Load and Download Data:

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

Build Complex Processing Chain:

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

Save and Validate Process Graph:

```python
with open("workflow.json", "w") as f:
    json.dump(graph, f, indent=2)

connection.validate_process_graph(graph)
print("✓ Graph validated and saved")
```{{exec}}

Band Mathematics:

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

Verify Band Calculation:

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

Once done, you can exit the python virtual environment:

```python
exit()
ls -lh *.nc *.json
deactivate
```{{exec}}

If you want to use the visual OpenEO Web Editor, you can connect to your instance via the [OpenEO Web Editor public Demo instance](https://editor.openeo.org/?server={{TRAFFIC_HOST1_81}}), and then authenticate with the user `testuser`{{copy}} and password `testuser123`{{copy}}. In the Web Editor, you can replicate what was done above by dragging boxes.


