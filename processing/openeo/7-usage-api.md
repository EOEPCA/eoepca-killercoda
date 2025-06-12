## Usage: Interacting with the API

You can interact with the OpenEO API directly using `curl` or other clients. As this is an open deployment, no authentication token is needed.

### Submit a Job

Here's an example that uses the "sum" process to add two numbers.

```bash
curl -X POST "https://openeo.${INGRESS_HOST}/openeo/1.2/result" \
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