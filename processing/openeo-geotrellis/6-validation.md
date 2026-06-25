Now validate the deployment directly through the OpenEO HTTP API.

Because OIDC is disabled, the workshop backend accepts a demo username and a password formed by appending `123` to that username. OpenEO transports these basic credentials inside a bearer token:

```bash
# Basic auth: password = username + "123"
export BASIC_AUTH=$(echo -n "testuser:testuser123" | base64)
echo "Auth token: ${BASIC_AUTH}"
```{{exec}}

Save the internal backend URL so the remaining commands are easier to read:

```bash
export OPENEO_URL=http://openeo.eoepca.local
```{{exec}}

We can now inspect the API capabilities:

```bash
curl -fsS "${OPENEO_URL}/openeo/1.2/" \
  | jq '{title, backend_version, api_version}'
```{{exec}}

Check that basic authentication is working:

```bash
curl -fsS -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/me" | jq .
```{{exec}}

We are now ready to run some example OpenEO API calls.

## Run Some Calculations

Add `15` and `27.5`. The expected response is `42.5`:
```bash
curl -fsS -X POST "${OPENEO_URL}/openeo/1.2/result" \
  -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  -H "Content-Type: application/json" \
  -d '{
    "process": {
      "process_graph": {
        "sum": {
          "process_id": "sum",
          "arguments": {"data": [15, 27.5]},
          "result": true
        }
      }
    }
  }'
echo ""
```{{exec}}

Select the value at zero-based index `2`. The expected response is `30`:
```bash
curl -fsS -X POST "${OPENEO_URL}/openeo/1.2/result" \
  -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  -H "Content-Type: application/json" \
  -d '{
    "process": {
      "process_graph": {
        "array1": {
          "process_id": "array_element",
          "arguments": {
            "data": [10, 20, 30, 40],
            "index": 2
          },
          "result": true
        }
      }
    }
  }'
echo ""
```{{exec}}

### Check What's Available

List the available collection IDs:
```bash
curl -fsS -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/collections" | jq '.collections[].id'
```{{exec}}

Summarise the test collection and its available bands:
```bash
curl -fsS -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/collections/TestCollection-LonLat16x16" \
  | jq '{
      id,
      description,
      spatial_extent: .extent.spatial.bbox,
      temporal_extent: .extent.temporal.interval,
      bands: .["cube:dimensions"].bands.values
    }'
```{{exec}}

Count the supported processes:
```bash
curl -fsS -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/processes" | jq '.processes | length'
```{{exec}}

Show a short sample of process names rather than printing the complete catalogue:
```bash
curl -fsS -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/processes" | jq -r '.processes[:20][].id'
```{{exec}}

List the supported input and output file formats:
```bash
curl -fsS -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/file_formats" | jq '{input: .input | keys, output: .output | keys}'
```{{exec}}
