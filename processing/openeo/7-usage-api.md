## Usage: Interacting with the API

You can interact with the OpenEO API directly using `curl`. As noted in the documentation for this lightweight service, you must use Basic Authentication with username `openeo` and password `openeo`.

### Submit a Job

Here's an example that uses the "sum" process to add two numbers. Note the `-u` flag for authentication and the updated URL.

```bash
curl -u openeo:openeo -X POST "http://openeo.${INGRESS_HOST}/result" \
  -H "Content-Type: application/json" \
  -d '{
        "process": {
          "process_graph": {
            "sum": {
              "process_id": "sum",
              "arguments": {
                "data": [15, 27.5]
              },
              "result": true
            }
          }
        }
      }'
```{{exec}}

You should see the result `42.5` returned, confirming that your OpenEO engine is processing jobs correctly.
