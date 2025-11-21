
Monitoring jobs is crucial for understanding processing status and debugging. Let's explore OpenEO's job monitoring capabilities:

```bash
cat <<'EOF' > monitor_jobs.py
import openeo
import json
from datetime import datetime

connection = openeo.connect("http://openeo.eoepca.local")

# List all jobs
print("=== All Jobs ===")
jobs = connection.list_jobs()
for job_metadata in jobs:
    print(f"Job ID: {job_metadata['id']}")
    print(f"  Title: {job_metadata.get('title', 'N/A')}")
    print(f"  Status: {job_metadata.get('status', 'unknown')}")
    print(f"  Created: {job_metadata.get('created', 'N/A')}")
    print(f"  Progress: {job_metadata.get('progress', 0)}%")
    print()

# Get detailed information about a specific job
if jobs:
    job_id = jobs[0]['id']
    job = connection.job(job_id)
    
    print(f"=== Detailed info for job {job_id} ===")
    print(f"Status: {job.status()}")
    print(f"Progress: {job.progress()}")
    
    # Get logs
    logs = job.logs()
    if logs:
        print("\nJob logs:")
        for log_entry in logs[:5]:  # Show first 5 log entries
            print(f"  [{log_entry.get('level')}] {log_entry.get('message')}")
    
    # Get results if finished
    if job.status() == "finished":
        results = job.get_results()
        print(f"\nResults: {results}")
        
        # Get STAC metadata for results
        stac_item = job.get_results_metadata()
        print(f"STAC Item: {json.dumps(stac_item, indent=2)}")
EOF
```

Run the monitoring script:

```bash
python monitor_jobs.py
```

Let's also check the Dask cluster status directly:

```bash
cat <<'EOF' > check_dask.py
import subprocess
import json

# Check Dask pods
print("=== Dask Pods ===")
result = subprocess.run(
    ["kubectl", "get", "pods", "-n", "dask", "-o", "json"],
    capture_output=True, text=True
)

if result.returncode == 0:
    pods = json.loads(result.stdout)
    for pod in pods.get('items', []):
        name = pod['metadata']['name']
        status = pod['status']['phase']
        
        # Check if it's a Dask worker or scheduler
        labels = pod['metadata'].get('labels', {})
        if 'dask.org/component' in labels:
            component = labels['dask.org/component']
            print(f"{name}: {component} - {status}")
            
            # Get resource usage
            containers = pod['spec']['containers']
            for container in containers:
                resources = container.get('resources', {})
                print(f"  Resources: {resources}")

# Check Dask Gateway status
print("\n=== Dask Gateway Status ===")
gateway_result = subprocess.run(
    ["kubectl", "get", "svc", "dask-gateway", "-n", "dask", "-o", "json"],
    capture_output=True, text=True
)

if gateway_result.returncode == 0:
    gateway = json.loads(gateway_result.stdout)
    print(f"Gateway endpoint: {gateway['spec']['clusterIP']}:{gateway['spec']['ports'][0]['port']}")
EOF
```

Run the Dask monitoring:

```bash
python check_dask.py
```

We can also check resource utilisation:

```bash
# Check node resources
kubectl top nodes

# Check pod resources in openeo namespace
kubectl top pods -n openeo

# Check pod resources in dask namespace  
kubectl top pods -n dask
```

This monitoring shows how OpenEO jobs translate into Dask clusters and how resources are allocated dynamically based on processing needs.

The OpenEO backend manages the complexity of:
- Creating Dask clusters on-demand
- Distributing processing across workers
- Managing data access and result storage
- Cleaning up resources after job completion

All whilst providing a simple, standardised API to users.
```