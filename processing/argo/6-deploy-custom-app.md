```bash
export OAPIP_HOST=http://localhost:8080

kubectl exec -n ns1 deployment/zoo-project-dru-zoofpm -- pip install --upgrade typing_extensions

```{{exec}}

## List Processes

Retrieve the list of available (currently deployed) processes.

```bash
curl --silent --show-error \
    -X GET "${OAPIP_HOST}/ogc-api/processes" \
    -H "Accept: application/json" \
    | jq '.processes[].id'
```{{exec}}

## Deploy Process convert

Deploy the convert app:

```bash
curl --silent --show-error \
    -X POST "${OAPIP_HOST}/ogc-api/processes" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d @- <<EOF | jq
{
    "executionUnit": {
        "href": "https://raw.githubusercontent.com/EOEPCA/deployment-guide/refs/heads/main/scripts/processing/oapip/examples/convert-url-app.cwl",
        "type": "application/cwl"
    }
}
EOF
```{{exec}}

Check the convert application is deployed:

```bash
curl --silent --show-error \
    -X GET "${OAPIP_HOST}/ogc-api/processes/convert-url" \
    -H "Accept: application/json" | jq
```{{exec}}

## Execute Process convert

```bash
JOB_ID=$(
    curl --silent --show-error \
        -X POST "${OAPIP_HOST}/ogc-api/processes/convert-url/execution" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -H "Prefer: respond-async" \
        -d @- <<EOF | jq -r '.jobID'
    {
        "inputs": {
            "fn": "resize",
            "url": "https://eoepca.org/media_portal/images/logo6_med.original.png",
            "size": "50%",
            "aws_access_key_id": "minio-admin",
            "aws_secret_access_key": "minio-secret-password",
            "region_name": "us-east-1",
            "endpoint_url": "http://s3-service.ns1.svc.cluster.local:9000",
            "s3_bucket": "results",
            "sub_path": "convert-url-test2"
        }
    }
EOF
)

echo "JOB ID: ${JOB_ID}"
```{{exec}}

## Check Execution Status

The JOB ID is used to monitor the progress of the job execution - most notably the status field that indicates whether the job is in-progress (running), or its completion status:

```bash
curl --silent --show-error \
    -X GET "${OAPIP_HOST}/ogc-api/jobs/${JOB_ID}" \
    -H "Accept: application/json" | jq
```{{exec}}

## Get Job Results

```bash
curl --silent --show-error \
    -X GET "${OAPIP_HOST}/ogc-api/jobs/${JOB_ID}/results" \
    -H "Accept: application/json" | jq
```{{exec}}

## Undeploy Process convert

```bash
curl --silent --show-error \
    -X DELETE "${OAPIP_HOST}/ogc-api/processes/convert-url" \
    -H "Accept: application/json" | jq
```{{exec}}
