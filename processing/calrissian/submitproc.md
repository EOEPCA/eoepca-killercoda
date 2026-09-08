Submit a job to resize the EOEPCA logo to 50% of its original width and height. Calrissian runs the application and stages its output to MinIO.

Inspect the inputs:

```
curl -sS http://zoo.eoepca.local/test/ogc-api/processes/convert-url | jq .inputs
```{{exec}}

Submit the execution asynchronously:

```
JOB_ID=$(
  curl --silent --show-error \
    -X POST http://zoo.eoepca.local/test/ogc-api/processes/convert-url/execution \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Prefer: respond-async" \
    -d @- <<EOF | jq -r '.jobID'
  {
    "inputs": {
      "fn": "resize",
      "url":  "https://eoepca.org/media_portal/images/logo6_med.original.png",
      "size": "50%"
    }
  }
EOF
)
echo "$JOB_ID"
```{{exec}}

The execution returns a job ID, which is saved in the `$JOB_ID`{{}} variable for later use.

Calrissian creates a dedicated namespace for this execution. Save its exact name as well:

```
JOB_NAMESPACE="convert-url-$JOB_ID"
echo "$JOB_NAMESPACE"
```{{exec}}
