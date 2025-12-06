## Using the OpenEO ArgoWorkflows API

This section demonstrates interacting with the OpenEO API. Note that this demo deployment uses basic authentication which allows API discovery, but full job submission requires OIDC authentication in production.

### API Discovery

Check the API root endpoint:
```bash
curl -s -u eoepcauser:eoepcapass http://openeo.eoepca.local/ | jq '{
  api_version: .api_version,
  backend_version: .backend_version,
  title: .title,
  endpoints: [.endpoints[].path]
}'
```{{exec}}

### Available Processes

OpenEO provides a rich set of processing functions. List all available processes:
```bash
curl -s -u eoepcauser:eoepcapass http://openeo.eoepca.local/processes | jq '[.processes[].id] | sort'
```{{exec}}

Get details about a specific process (e.g., NDVI calculation):
```bash
curl -s -u eoepcauser:eoepcapass http://openeo.eoepca.local/processes | jq '.processes[] | select(.id=="ndvi")'
```{{exec}}


### Check Conformance

See which standards the API conforms to:
```bash
curl -s -u eoepcauser:eoepcapass http://openeo.eoepca.local/conformance | jq '.'
```{{exec}}

### Authentication Information

View the OIDC provider configuration:
```bash
curl -s -u eoepcauser:eoepcapass http://openeo.eoepca.local/credentials/oidc | jq '.'
```{{exec}}

### Understanding Process Graphs

OpenEO uses process graphs to define workflows. Here's an example structure for calculating NDVI:
```bash
cat << 'EOF'
{
  "process_graph": {
    "load": {
      "process_id": "load_collection",
      "arguments": {
        "id": "sentinel-2-l2a",
        "spatial_extent": {"west": 11.2, "south": 46.4, "east": 11.5, "north": 46.6},
        "temporal_extent": ["2023-06-01", "2023-06-30"],
        "bands": ["B04", "B08"]
      }
    },
    "ndvi": {
      "process_id": "ndvi",
      "arguments": {
        "data": {"from_node": "load"},
        "nir": "B08",
        "red": "B04"
      }
    },
    "save": {
      "process_id": "save_result",
      "arguments": {
        "data": {"from_node": "ndvi"},
        "format": "GTiff"
      },
      "result": true
    }
  }
}
EOF
```{{exec}}
