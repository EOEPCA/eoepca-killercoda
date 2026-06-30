We now have the `convert-url`{{}} application deployed on our platform and can submit a processing request.

Once the request is submitted, ZOO-Project prepares a wrapped CWL workflow and sends it to Toil WES. Toil submits the application jobs to HTCondor, and the final workflow step pushes the output into the platform object storage.

Through the [OGC API - Processes](https://ogcapi.ogc.org/processes/) interface, we can monitor the job status and retrieve its output after successful completion.

First, check the inputs required by the application:

```
curl --silent --show-error \
  http://zoo.eoepca.local/test/ogc-api/processes/convert-url \
  | jq '.inputs'
```{{exec}}

As shown in the CWL, the application accepts three inputs: `fn`, `url`, and `size`.

Submit an asynchronous execution using their example values:

```
JOB_ID=$(
  curl --fail --silent --show-error \
    --request POST \
    --header "Content-Type: application/json" \
    --header "Accept: application/json" \
    --header "Prefer: respond-async" \
    --data @- \
    http://zoo.eoepca.local/test/ogc-api/processes/convert-url/execution <<EOF \
  | jq -er '.jobID'
{
  "inputs": {
    "fn": "resize",
    "url": "https://raw.githubusercontent.com/github/explore/main/topics/kubernetes/kubernetes.png",
    "size": "50%"
  }
}
EOF
)
echo "Job ID: $JOB_ID"
```{{exec}}

The API returns a job identifier, which is saved in the `$JOB_ID`{{}} variable for the monitoring commands in the next step. The `--fail` and `jq -e` options prevent an HTTP error or missing job ID from being silently accepted.
