Now that Resource Health is deployed, create and run a health check.

### View the available templates

List the installed check templates:

```bash
curl -sS "http://resource-health.eoepca.local/api/healthchecks/v1/check_templates/" \
  | jq '.data[] | {id, description: .attributes.metadata.description}'
```{{exec}}

The deployment includes:

- `simple_ping` — checks an HTTP endpoint and its response status
- `generic_script_template` — runs a user-provided pytest script

Inspect the input schema for `simple_ping`:

```bash
curl -sS "http://resource-health.eoepca.local/api/healthchecks/v1/check_templates/simple_ping" \
  | jq '.data.attributes'
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

The current `healthcheck_runner:2.0.0` image needs an older setuptools release
for its OpenTelemetry launcher. Add this temporary compatibility command to the
generated CronJob:

```bash
kubectl set env cronjob/"$CHECK_ID" -n resource-health \
  RH_RUNNER_RUN_BEFORE="uv pip install 'setuptools<81'"
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

OpenTelemetry batches results before writing them to OpenSearch. Poll for up to
30 seconds for the first result:

```bash
for attempt in {1..6}; do
  TELEMETRY=$(curl -sS \
    "http://resource-health.eoepca.local/api/telemetry/v1/spans")
  RESULT_COUNT=$(echo "$TELEMETRY" \
    | jq '.data[0].attributes.resourceSpans | length')
  [ "$RESULT_COUNT" -gt 0 ] && break
  sleep 5
done

echo "$TELEMETRY" | jq '{
  result_count: (.data[0].attributes.resourceSpans | length),
  health_checks: [
    .data[0].attributes.resourceSpans[]?.resource.attributes[]?
    | select(.key == "health_check.name")
    | .value.stringValue
  ] | unique
}'
```{{exec}}

You should see `mock-service-check` in the telemetry results.

### Monitor another Resource Health component

Create a second check that monitors the Resource Health web service itself:

```bash
cat <<'EOF' > healthcheck-web.json
{
  "data": {
    "type": "check",
    "attributes": {
      "schedule": "*/10 * * * *",
      "metadata": {
        "name": "resource-health-web-check",
        "description": "Check the Resource Health web service",
        "template_id": "simple_ping",
        "template_args": {
          "endpoint": "http://resource-health-web:80/",
          "expected_status_code": 200
        }
      }
    }
  }
}
EOF

WEB_RESPONSE=$(curl -sS -X POST \
  "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" \
  -H "Content-Type: application/vnd.api+json" \
  -d @healthcheck-web.json)

echo "$WEB_RESPONSE" | jq
WEB_CHECK_ID=$(echo "$WEB_RESPONSE" | jq -r '.data.id')
kubectl set env cronjob/"$WEB_CHECK_ID" -n resource-health \
  RH_RUNNER_RUN_BEFORE="uv pip install 'setuptools<81'"
```{{exec}}

List the registered checks and their schedules:

```bash
curl -sS "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" \
  | jq '.data[] | {
      id,
      name: .attributes.metadata.name,
      schedule: .attributes.schedule
    }'
```{{exec}}

Open the [Resource Health dashboard]({{TRAFFIC_HOST1_81}}) to view the two
checks. The dashboard uses the same Health Checks and Telemetry APIs exercised
above.

### Delete a health check

Delete the second check through the API:

```bash
curl -sS -X DELETE \
  "http://resource-health.eoepca.local/api/healthchecks/v1/checks/${WEB_CHECK_ID}"

curl -sS "http://resource-health.eoepca.local/api/healthchecks/v1/checks/" \
  | jq '.data[].attributes.metadata.name'
```{{exec}}

The API also removes its CronJob:

```bash
kubectl get cronjobs -n resource-health
```{{exec}}
