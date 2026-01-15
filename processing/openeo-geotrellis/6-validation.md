To check if the OpenEO backend is working properly, we can first directly query the OpenEO APIs.

To do so, we need first to setup authentication. As we disabled OIDC, we need to use the hardocded test basic authentication, via

```bash
# Basic auth: password = username + "123"
export BASIC_AUTH=$(echo -n "testuser:testuser123" | base64)
echo "Auth token: ${BASIC_AUTH}"
```{{exec}}

and we save the local OpenEO backend endpoint via

```bash
export OPENEO_URL=http://openeo.eoepca.local
```{{exec}}

We can now check the API is running (if this fails just wait a minute for the service to fully boot up):
```bash
curl -s "${OPENEO_URL}/openeo/1.2/" | jq '{title, backend_version, api_version}'
```{{exec}}

and that authentication is working:
```bash
curl -s -H "Authorization: Bearer basic/openeo/${BASIC_AUTH}" \
  "${OPENEO_URL}/openeo/1.2/me" | jq .
```{{exec}}

and we are ready to run the following example OpenEO API calls:

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

Process count (156 available):
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
