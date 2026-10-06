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

The runner sends its results through the OpenTelemetry Collector to OpenSearch.
Ask the Telemetry API for the `test run` span of `mock-service-check`:

```bash
curl -sS -G "http://resource-health.eoepca.local/api/telemetry/v1/spans" \
  --data-urlencode 'resource_attributes=health_check.name="mock-service-check"' \
  --data-urlencode 'span_name=test run' \
  | jq
```{{exec}}

Each run of the check records one `test run` span. Its resource attributes
include the check name and the CronJob UUID (`k8s.cronjob.name`), and
`"status": {"code": 1}` means the check passed. OpenTelemetry batches results
before writing them to OpenSearch. If `data` is empty, run the command again
after a few seconds.

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

Query the recorded result for the new check:

```bash
curl -sS -G "http://resource-health.eoepca.local/api/telemetry/v1/spans" \
  --data-urlencode 'resource_attributes=health_check.name="mock-missing-page-check"' \
  --data-urlencode 'span_name=test run' \
  | jq
```{{exec}}

This time the span has `"status": {"code": 2}`, which means the check failed.
If `data` is empty, repeat the request after a few seconds.

### Write your own check

`generic_script_template` runs any pytest script, so a check can test the
content of a response as well as its status. The mock service returns the total
of two dice rolls. This script checks that the total is between 2 and 12:

```bash
cat <<'EOF' > dice_check.py
import requests


def test_dice_total():
    response = requests.get("http://resource-health-mock-api:5000/", timeout=10)
    assert response.status_code == 200
    assert 2 <= int(response.text) <= 12
EOF
```{{exec}}

The template takes the script as a URL. Pass the file as a base64 `data:` URL
and register the check:

```bash
SCRIPT_URL="data:text/plain;base64,$(base64 -w0 dice_check.py)"

cat <<EOF > healthcheck-dice.json
{
  "data": {
    "type": "check",
    "attributes": {
      "schedule": "*/10 * * * *",
      "metadata": {
        "name": "mock-dice-check",
        "description": "Check the mock service returns a valid dice total",
        "template_id": "generic_script_template",
        "template_args": {
          "script": "$SCRIPT_URL"
        }
      }
    }
  }
}
EOF

DICE_RESPONSE=$(curl -sS -X POST \
  "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" \
  -H "Content-Type: application/vnd.api+json" \
  -d @healthcheck-dice.json)

echo "$DICE_RESPONSE" | jq
DICE_CHECK_ID=$(echo "$DICE_RESPONSE" | jq -r '.data.id')
```{{exec}}

Run it now and inspect the output:

```bash
kubectl delete job manual-dice-check -n resource-health --ignore-not-found
kubectl create job --from=cronjob/"$DICE_CHECK_ID" \
  manual-dice-check -n resource-health
kubectl wait --for=condition=complete job/manual-dice-check \
  -n resource-health --timeout=180s
kubectl logs job/manual-dice-check -n resource-health --all-containers \
  | tail -20
```{{exec}}

The pytest summary should report `1 passed` for `test_dice_total`. The result
is recorded in the same way as the `simple_ping` checks.

### Inspect the dashboard

Open the [Resource Health dashboard]({{TRAFFIC_HOST1_81}}). Compare
`mock-service-check` with `mock-missing-page-check`, then open each check to
inspect its recorded run and test result. The missing-page check should show
`FAIL 1` and `assert 404 == 200`; the original check should show `PASS 1`.
`mock-dice-check` should also show `PASS 1`. Refresh after a few seconds if
telemetry is still arriving.

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

Keep `mock-service-check` and `mock-dice-check` running. They continue to check
the mock service on their schedules, so you can follow later results in the
dashboard.
