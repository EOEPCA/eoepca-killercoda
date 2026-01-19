Now that we have our Resource Health system deployed, let's create and run a health check.

### View Available Templates

First, let's see what health check templates are available:

```
curl -s "http://resource-health.eoepca.local/api/healthchecks/v1/check_templates/" | jq '.data[].id'
```{{exec}}

You should see two templates:
- `simple_ping` - For checking if an endpoint responds with an expected HTTP status code
- `generic_script_template` - For running custom pytest scripts

Let's look at the details of the `simple_ping` template:

```
curl -s "http://resource-health.eoepca.local/api/healthchecks/v1/check_templates/simple_ping" | jq
```{{exec}}

### Create a Health Check

The Resource Health API uses JSON:API format. Let's create a health check that verifies Google is reachable:

```
cat <<EOF | tee healthcheck-google.json | jq
{
  "data": {
    "type": "check",
    "attributes": {
      "schedule": "*/5 * * * *",
      "metadata": {
        "name": "google-ping-check",
        "description": "Check if Google is reachable",
        "template_id": "simple_ping",
        "template_args": {
          "endpoint": "https://www.google.com",
          "expected_status_code": 200
        }
      }
    }
  }
}
EOF
```{{exec}}

This health check will run every 5 minutes and verify that Google returns a 200 status code.

Now let's register this health check:

```
curl -X POST "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" \
  -H "Content-Type: application/vnd.api+json" \
  -d @healthcheck-google.json | jq
```{{exec}}

Note the `id` field in the response - this is the UUID assigned to your health check.

### List Health Checks

We can see all registered health checks:

```
curl -s "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" | jq '.data[] | {id: .id, name: .attributes.metadata.name, schedule: .attributes.schedule}'
```{{exec}}

### View the CronJob

The health check is implemented as a Kubernetes CronJob. Let's view it:

```
kubectl get cronjobs -n resource-health
```{{exec}}

The CronJob name matches the UUID of the health check.

### Trigger a Health Check Manually

Rather than waiting for the scheduled time, we can trigger a health check manually by creating a Job from the CronJob. First, get the check ID:

```
CHECK_ID=$(curl -s "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" | jq -r '.data[0].id')
echo "Check ID: $CHECK_ID"
```{{exec}}

Now create a manual job:

```
kubectl create job --from=cronjob/${CHECK_ID} manual-google-check -n resource-health
```{{exec}}

Wait for the job to complete:

```
kubectl wait --for=condition=complete job/manual-google-check -n resource-health --timeout=120s
```{{exec}}

### View Job Results

Let's check the job status and logs:

```
kubectl get jobs -n resource-health
```{{exec}}

```
kubectl logs job/manual-google-check -n resource-health --all-containers 2>/dev/null | tail -15
```{{exec}}

You should see pytest output showing the test passed.

### Create a Second Health Check

Let's create another health check that tests a different endpoint - the Kubernetes API server:

```
cat <<EOF | tee healthcheck-k8s.json | jq
{
  "data": {
    "type": "check",
    "attributes": {
      "schedule": "*/10 * * * *",
      "metadata": {
        "name": "k8s-api-check",
        "description": "Check if Kubernetes API is responding",
        "template_id": "simple_ping",
        "template_args": {
          "endpoint": "https://kubernetes.default.svc.cluster.local/healthz",
          "expected_status_code": 401
        }
      }
    }
  }
}
EOF
```{{exec}}

Note: We expect a 401 (Unauthorized) because we're not providing authentication, but this confirms the API server is responding.

Register it:

```
curl -X POST "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" \
  -H "Content-Type: application/vnd.api+json" \
  -d @healthcheck-k8s.json | jq
```{{exec}}

### Query Telemetry Results

After health checks have run, results are stored in OpenSearch and can be queried via the Telemetry API:

```
curl -s "http://resource-health.eoepca.local/api/telemetry/v1/spans/" | jq
```{{exec}}

If no data appears yet, wait a moment for the checks to complete and telemetry to be collected.

### Get Details of a Specific Check

To get details about a specific health check using its ID:

```
CHECK_ID=$(curl -s "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" | jq -r '.data[0].id')
curl -s "http://resource-health.eoepca.local/api/healthchecks/v1/checks/${CHECK_ID}" | jq
```{{exec}}

### Delete a Health Check

To remove a health check, use the DELETE endpoint with the check ID:

```
# Get the k8s-api-check ID
K8S_CHECK_ID=$(curl -s "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" | jq -r '.data[] | select(.attributes.metadata.name=="k8s-api-check") | .id')
echo "Deleting check: $K8S_CHECK_ID"

curl -X DELETE "http://resource-health.eoepca.local/api/healthchecks/v1/checks/${K8S_CHECK_ID}" | jq
```{{exec}}

Verify it's been removed:

```
curl -s "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" | jq '.data[].attributes.metadata.name'
```{{exec}}

The corresponding CronJob should also be deleted:

```
kubectl get cronjobs -n resource-health
```{{exec}}
