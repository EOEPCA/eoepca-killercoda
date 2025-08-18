## Using the OpenEO API

### Set Up Authentication

```bash
# Basic auth: password = username + "123"
export BASIC_AUTH=$(echo -n "testuser:testuser123" | base64)
echo "Auth token: ${BASIC_AUTH}"
```{{exec}}

## Quick Tests

Check the API is running (if this fails just wait a minute for the service to fully boot up):
```bash
curl -s "${OPENEO_URL}/openeo/1.2/" | jq '{title, backend_version, api_version}'
```{{exec}}

Test authentication:
```bash
curl -s -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/me" | jq .
```{{exec}}

## Run Some Calculations

Simple sum:
```bash
curl -s -X POST "${OPENEO_URL}/openeo/1.2/result" \
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

Find index in array
```bash
curl -s -X POST "${OPENEO_URL}/openeo/1.2/result" \
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

Collections:
```bash
curl -s -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/collections" | jq '.collections[].id'
```{{exec}}

View Collection (TestCollection-LonLat16x16)
```bash
curl -s -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/collections/TestCollection-LonLat16x16" | jq .
```{{exec}}

Process count (142 available):
```bash
curl -s -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/processes" | jq '.processes | length'
```{{exec}}

Process names:
```bash
curl -s -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/processes" | jq '.processes[].id'
```{{exec}}

File formats:
```bash
curl -s -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/file_formats" | jq '{input: .input | keys, output: .output | keys}'
```{{exec}}
