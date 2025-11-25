## Using the OpenEO ArgoWorkflows API

### Basic Authentication Setup

For demo purposes, we're using basic auth:

```bash
# Demo credentials
export AUTH_USER="demo"
export AUTH_PASS="demo123"
export BASIC_AUTH=$(echo -n "${AUTH_USER}:${AUTH_PASS}" | base64)
echo "Auth configured for user: ${AUTH_USER}"
```{{exec}}

### API Discovery

Check available endpoints:
```bash
curl -s "http://localhost:8080/" | jq '.endpoints | keys'
```{{exec}}

Get backend capabilities:
```bash
curl -s "http://localhost:8080/" | jq '{
  api_version: .api_version,
  backend_version: .backend_version,
  processing: .processing,
  output_formats: .output_formats
}'
```{{exec}}

### Collections and Processes

List available collections:
```bash
curl -s -H "Authorization: Basic ${BASIC_AUTH}" \
  "http://localhost:8080/collections" | jq '.collections[].id' 2>/dev/null || echo "No collections available in demo mode"
```{{exec}}

List available processes (processing functions):
```bash
curl -s "http://localhost:8080/processes" | jq '.processes[:5] | .[].id'
```{{exec}}

Get details of a specific process:
```bash
curl -s "http://localhost:8080/processes" | jq '.processes[] | select(.id=="ndvi") | {id, summary, parameters}'
```{{exec}}

### Submit a Simple Calculation

```
curl  -L -u eoepcauser:eoepcapass https://openeo.${INGRESS_HOST}/result \
  -H "Content-Type: application/json" \
  -d '{
    "process": {
      "process_graph": {
        "multiply": {
          "process_id": "multiply",
          "arguments": {"x": 7, "y": 6},
          "result": true
        }
      }
    }
  }'
```{{exec}}

Test with basic arithmetic:
```bash
curl -s -X POST "http://localhost:8080/result" \
  -H "Authorization: Basic ${BASIC_AUTH}" \
  -H "Content-Type: application/json" \
  -d '{
    "process": {
      "process_graph": {
        "multiply": {
          "process_id": "multiply",
          "arguments": {"x": 7, "y": 6},
          "result": true
        }
      }
    }
  }'
echo ""
```{{exec}}

### Create a Process Graph

Build a more complex processing chain:
```bash
cat > process_graph.json <<EOF
{
  "process": {
    "process_graph": {
      "array1": {
        "process_id": "create_array",
        "arguments": {
          "data": [10, 20, 30, 40, 50]
        }
      },
      "mean1": {
        "process_id": "mean",
        "arguments": {
          "data": {"from_node": "array1"}
        }
      },
      "multiply1": {
        "process_id": "multiply",
        "arguments": {
          "x": {"from_node": "mean1"},
          "y": 2
        },
        "result": true
      }
    }
  }
}
EOF

curl -s -X POST "http://localhost:8080/result" \
  -H "Authorization: Basic ${BASIC_AUTH}" \
  -H "Content-Type: application/json" \
  -d @process_graph.json
echo ""
```{{exec}}

### Submit a Batch Job

Create a batch job (runs asynchronously):
```bash
cat > batch_job.json <<EOF
{
  "title": "Demo Batch Job",
  "description": "Calculate statistics on array data",
  "process": {
    "process_graph": {
      "data1": {
        "process_id": "create_array",
        "arguments": {
          "data": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        }
      },
      "stats": {
        "process_id": "aggregate_statistics",
        "arguments": {
          "data": {"from_node": "data1"}
        },
        "result": true
      }
    }
  }
}
EOF

# Note: In full deployment, this would trigger Dask workers
JOB_ID=$(curl -s -X POST "http://localhost:8080/jobs" \
  -H "Authorization: Basic ${BASIC_AUTH}" \
  -H "Content-Type: application/json" \
  -d @batch_job.json | jq -r '.id' 2>/dev/null || echo "job-demo-001")

echo "Job created with ID: ${JOB_ID}"
```{{exec}}