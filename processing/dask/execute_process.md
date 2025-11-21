
Now let's execute our process graphs. OpenEO supports both synchronous and batch (asynchronous) processing.

Create a script to submit a batch job:

```bash
cat <<'EOF' > execute_job.py
import openeo
import json
import time

# Connect to backend
connection = openeo.connect("http://openeo.eoepca.local")

# Create a simple process
bbox = {"west": 11.2, "south": 46.2, "east": 11.3, "north": 46.3}
datacube = connection.load_collection(
    "sentinel-2-l2a",
    spatial_extent=bbox,
    temporal_extent=["2023-07-01", "2023-07-07"],
    bands=["B04", "B03", "B02"]
)

# Apply simple processing - calculate mean over time
temporal_mean = datacube.reduce_dimension(dimension="t", reducer="mean")

# Create batch job
job = temporal_mean.create_job(
    title="Demo RGB Composite",
    description="Calculate temporal mean RGB composite"
)

print(f"Job created with ID: {job.job_id}")
print(f"Job status: {job.status()}")

# Start the job
job.start()
print("Job started!")

# Monitor job progress
while job.status() in ["created", "queued", "running"]:
    status = job.status()
    print(f"Job status: {status}")
    
    # Check if Dask cluster has been created
    dask_pods = subprocess.run(
        ["kubectl", "get", "pods", "-n", "dask", "-l", f"job-id={job.job_id}"],
        capture_output=True, text=True
    )
    if dask_pods.stdout:
        print("Dask workers:")
        print(dask_pods.stdout)
    
    time.sleep(5)

final_status = job.status()
print(f"\nJob completed with status: {final_status}")

if final_status == "finished":
    # Get results
    results = job.get_results()
    print(f"Results available at: {results}")
    
    # Download results
    job.download_results("./results/")
    print("Results downloaded to ./results/")
else:
    # Get error logs if job failed
    logs = job.logs()
    print(f"Job logs: {logs}")
EOF
```

Run the job execution:

```bash
mkdir -p results
python execute_job.py
```

The job will trigger the Dask backend to:
1. Create a new Dask cluster via Dask Gateway
2. Distribute the processing across Dask workers
3. Store results in the configured S3 storage

Let's also create a script for synchronous processing (for smaller requests):

```bash
cat <<'EOF' > execute_sync.py
import openeo

connection = openeo.connect("http://openeo.eoepca.local")

# Small area for quick processing
small_bbox = {"west": 11.25, "south": 46.25, "east": 11.26, "north": 46.26}

cube = connection.load_collection(
    "sentinel-2-l2a",
    spatial_extent=small_bbox,
    temporal_extent=["2023-07-15", "2023-07-15"],
    bands=["B04"]
)

# Simple calculation
result = cube.reduce_dimension(dimension="bands", reducer="mean")

# Execute synchronously
print("Executing synchronous request...")
result.download("./sync_result.tif", format="GTiff")
print("Result saved to sync_result.tif")
EOF
```

This demonstrates both batch and synchronous execution modes available in OpenEO.