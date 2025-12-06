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
curl -s -u eoepcauser:eoepcapass -X POST \
  -H "Content-Type: application/json" \
  http://openeo.eoepca.local/result \
  -d '{
    "process": {
      "process_graph": {
        "add1": {
          "process_id": "add",
          "arguments": {"x": 3, "y": 5},
          "result": true
        }
      }
    }
  }'
```{{exec}}
