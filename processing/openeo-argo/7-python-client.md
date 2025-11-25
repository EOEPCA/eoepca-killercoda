## Using the OpenEO Python Client

### Install Dependencies

```bash
apt update && apt install -y python3.12-venv python3-pip
python3 -m venv venv
source venv/bin/activate
pip install openeo requests pandas numpy
```{{exec}}

### Python Session

Start Python:
```bash
python3
```{{exec}}

Import and connect:
```python
import openeo
import json
import os

# Connect to local instance
openeo_url = "http://localhost:8080"
print(f"Connecting to {openeo_url}")

# Create connection
connection = openeo.connect(openeo_url)
print(f"Backend: {connection.describe_account()}")
```{{exec}}

Authenticate (demo mode):
```python
# For demo, using basic auth
connection.authenticate_basic("demo", "demo123")
print("Authenticated")
```{{exec}}

### Explore Available Resources

```python
# Check API version
info = connection.capabilities()
print(f"API Version: {info.api_version()}")

# List processes
processes = connection.list_processes()
print(f"Available processes: {len(processes)}")
print("Sample processes:", [p['id'] for p in processes[:5]])
```{{exec}}

### Build and Execute Process Graphs

Simple calculation:
```python
# Create a simple calculation
from openeo.processes import multiply, add, divide

result = connection.execute({
    "add1": {
        "process_id": "add",
        "arguments": {"x": 10, "y": 20}
    },
    "multiply1": {
        "process_id": "multiply", 
        "arguments": {
            "x": {"from_node": "add1"},
            "y": 3
        },
        "result": True
    }
})
print(f"Result: {result}")
```{{exec}}

### Working with Arrays and Statistics

```python
# Array operations
graph = {
    "array1": {
        "process_id": "create_array",
        "arguments": {
            "data": [15, 22, 8, 45, 33, 12, 67, 29]
        }
    },
    "sorted": {
        "process_id": "sort",
        "arguments": {
            "data": {"from_node": "array1"}
        }
    },
    "median": {
        "process_id": "median",
        "arguments": {
            "data": {"from_node": "sorted"}
        },
        "result": True
    }
}

result = connection.execute({"process": {"process_graph": graph}})
print(f"Median of array: {result}")
```{{exec}}

### Create a Batch Job

```python
# Define a more complex processing job
job_graph = {
    "load_data": {
        "process_id": "create_array",
        "arguments": {
            "data": list(range(1, 101))  # Numbers 1-100
        }
    },
    "filter_even": {
        "process_id": "filter",
        "arguments": {
            "data": {"from_node": "load_data"},
            "condition": {
                "process_graph": {
                    "mod": {
                        "process_id": "mod",
                        "arguments": {
                            "x": {"from_parameter": "x"},
                            "y": 2
                        }
                    },
                    "eq": {
                        "process_id": "eq",
                        "arguments": {
                            "x": {"from_node": "mod"},
                            "y": 0
                        },
                        "result": True
                    }
                }
            }
        }
    },
    "sum_result": {
        "process_id": "sum",
        "arguments": {
            "data": {"from_node": "filter_even"}
        },
        "result": True
    }
}

# In full deployment, this would create a Dask-powered job
print("Process graph created for summing even numbers from 1-100")
print(json.dumps(job_graph, indent=2))
```{{exec}}

### Dask Integration (Conceptual)

```python
# In production, OpenEO ArgoWorkflows uses Dask for distributed processing
# Here's how it would work conceptually:

dask_config = {
    "workers": 4,
    "memory_per_worker": "4GB",
    "cores_per_worker": 2
}

print("Dask configuration for production:")
print(json.dumps(dask_config, indent=2))

# The actual Dask cluster scales automatically based on job requirements
print("\nDask advantages:")
print("- Dynamic scaling based on workload")
print("- Python-native processing") 
print("- Efficient memory management")
print("- Built-in fault tolerance")
```{{exec}}

Exit Python:
```python
exit()
```{{exec}}

Deactivate virtual environment:
```bash
deactivate
```{{exec}}