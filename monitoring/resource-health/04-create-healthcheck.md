Now that Resource Health is deployed, create and run a health check.

### View the available templates

List the installed check templates:

```bash
curl -sS "http://resource-health.eoepca.local/api/healthchecks/v1/check_templates/" \
  | jq
```{{exec}}

The deployment includes:

- `simple_ping` — checks an HTTP endpoint and its response status
- `generic_script_template` — runs a user-provided pytest script

Inspect the input schema for `simple_ping`:

```bash
curl -sS "http://resource-health.eoepca.local/api/healthchecks/v1/check_templates/simple_ping" \
  | jq
```{{exec}}

### Create a health check

Create a scheduled check for the mock service included in the Resource Health
deployment. Using an in-cluster target keeps this workshop independent of
external internet access:

```bash
cat <<'EOF' > healthcheck-mock.json
{
  "data": {
    "type": "check",
    "attributes": {
      "schedule": "*/5 * * * *",
      "metadata": {
        "name": "mock-service-check",
        "description": "Check the bundled Resource Health mock service",
        "template_id": "simple_ping",
        "template_args": {
          "endpoint": "http://resource-health-mock-api:5000/",
          "expected_status_code": 200
        }
      }
    }
  }
}
EOF

jq . healthcheck-mock.json
```{{exec}}

Register it and retain the generated check ID:

```bash
CREATE_RESPONSE=$(curl -sS -X POST \
  "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" \
  -H "Content-Type: application/vnd.api+json" \
  -d @healthcheck-mock.json)

echo "$CREATE_RESPONSE" | jq
CHECK_ID=$(echo "$CREATE_RESPONSE" | jq -r '.data.id')
echo "Check ID: $CHECK_ID"
```{{exec}}

The API creates a Kubernetes CronJob with the same UUID:

```bash
kubectl get cronjob "$CHECK_ID" -n resource-health
```{{exec}}

### Run the check now

Rather than waiting for the five-minute schedule, create a one-off Job from the
CronJob:

```bash
kubectl delete job manual-mock-check -n resource-health --ignore-not-found
kubectl create job --from=cronjob/"$CHECK_ID" \
  manual-mock-check -n resource-health
kubectl wait --for=condition=complete job/manual-mock-check \
  -n resource-health --timeout=180s
```{{exec}}

Inspect the result:

```bash
kubectl get job manual-mock-check -n resource-health
kubectl logs job/manual-mock-check -n resource-health --all-containers \
  | tail -20
```{{exec}}

The pytest summary should report `1 passed`.

### Query the recorded telemetry

Query the Telemetry API:

```bash
curl -sS "http://resource-health.eoepca.local/api/telemetry/v1/spans" | jq
```{{exec}}

Look for `mock-service-check` in the response. OpenTelemetry batches results
before writing them to OpenSearch. If the result has not appeared yet, run the
command again after a few seconds.

### Compare a failed check

Create a check for a missing page on the same mock service. It expects HTTP 200,
but the service returns 404:

```bash
cat <<'EOF' > healthcheck-missing.json
{
  "data": {
    "type": "check",
    "attributes": {
      "schedule": "*/10 * * * *",
      "metadata": {
        "name": "mock-missing-page-check",
        "description": "Demonstrate a failed check against a missing page",
        "template_id": "simple_ping",
        "template_args": {
          "endpoint": "http://resource-health-mock-api:5000/missing-page",
          "expected_status_code": 200
        }
      }
    }
  }
}
EOF

FAILED_RESPONSE=$(curl -sS -X POST \
  "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" \
  -H "Content-Type: application/vnd.api+json" \
  -d @healthcheck-missing.json)

echo "$FAILED_RESPONSE" | jq
FAILED_CHECK_ID=$(echo "$FAILED_RESPONSE" | jq -r '.data.id')

kubectl delete job manual-missing-check -n resource-health --ignore-not-found
kubectl create job --from=cronjob/"$FAILED_CHECK_ID" \
  manual-missing-check -n resource-health
kubectl wait --for=condition=complete job/manual-missing-check \
  -n resource-health --timeout=180s
kubectl logs job/manual-missing-check -n resource-health --all-containers \
  | tail -30
```{{exec}}

The pytest summary should report `1 failed`, with HTTP 404 instead of 200.
The runner records test failures without failing the Kubernetes Job: a completed
Job means the runner finished, not that the monitored service passed its check.

Query the recorded results again:

```bash
curl -sS "http://resource-health.eoepca.local/api/telemetry/v1/spans" | jq
```{{exec}}

Look for `mock-missing-page-check` and its error status. If it has not appeared
yet, repeat the request after a few seconds.

### Inspect the dashboard

Open the [Resource Health dashboard]({{TRAFFIC_HOST1_81}}). Compare
`mock-service-check` with `mock-missing-page-check`, then open each check to
inspect its recorded run and test result. The missing-page check should show
`FAIL 1` and `assert 404 == 200`; the original check should show `PASS 1`.
Refresh after a few seconds if telemetry is still arriving.

List the registered checks and their schedules:

```bash
curl -sS "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" | jq
```{{exec}}

### Delete a health check

Remove the deliberately failing check through the API:

```bash
curl -sS -X DELETE \
  "http://resource-health.eoepca.local/api/healthchecks/v1/checks/${FAILED_CHECK_ID}"

curl -sS "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" \
  | jq
```{{exec}}

The API also removes its CronJob:

```bash
kubectl get cronjobs -n resource-health
```{{exec}}

Keep `mock-service-check` running. It continues to check the mock service every
five minutes, so you can follow later results in the dashboard.
