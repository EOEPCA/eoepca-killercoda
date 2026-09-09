Use the service from the previous page to follow an alert through Prometheus, Alertmanager and Keep, then restore it. Continue in the same terminal so the Grafana credentials and `DEMO_URL` remain available.

Each API request below saves a response and displays the full JSON. The short `jq` command that follows shows the key fields. To check progress, rerun the request first: filtering a saved response does not refresh it.

## Stop the service

Stop the sample service:

```
kubectl -n operations scale deployment/operations-demo --replicas=0
```{{exec}}

In Grafana **Explore**, select **Prometheus** and check the replica count:

```promql
kube_deployment_status_replicas_available{namespace="operations", deployment="operations-demo"}
```

The value should fall to `0`. Query the alert state in the terminal:

```
ALERT_STATE_RESPONSE=$(curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" -G \
  "$GRAFANA_URL/api/datasources/proxy/uid/prometheus/api/v1/query" \
  --data-urlencode 'query=ALERTS{alertname="TutorialServiceUnavailable"}')
printf '%s\n' "$ALERT_STATE_RESPONSE" | jq
```{{exec}}

Show just the Prometheus alert state:

```
printf '%s\n' "$ALERT_STATE_RESPONSE" | jq -r '.data.result[].metric.alertstate'
```{{exec}}

The short output is initially empty, then `pending`, then `firing`. The rule must remain pending for one minute. Allow another minute for scraping and delivery; rerun the request and status command to check progress. Continue once it shows `firing`.

## Follow the alert to Keep

Once the alert is firing, check that Alertmanager has received it:

```
kubectl -n operations exec alertmanager-kube-prometheus-stack-alertmanager-0 -- \
  wget -qO- http://localhost:9093/api/v2/alerts | jq
```{{exec}}

Find `TutorialServiceUnavailable` under `labels.alertname`. The receiver `operations/keep/keep` routes it through the relay to Keep.

[Open Keep]({{TRAFFIC_HOST1_82}}) and select **Alerts → Feed**. Find **TutorialServiceUnavailable**. The continuously firing **Watchdog** alert should also be present.

List the same alerts through the API. Keep requires the API-key header even in unauthenticated mode, where any value is accepted:

```
ALERTS_RESPONSE=$(curl -sS http://alerting.eoepca.local/v2/alerts \
  -H 'X-API-KEY: anything')
printf '%s\n' "$ALERTS_RESPONSE" | jq
```{{exec}}

Show each alert's name, status and fingerprint:

```
printf '%s\n' "$ALERTS_RESPONSE" | jq '.[] | {name, status, fingerprint}'
```{{exec}}

## Acknowledge the alert

Extract the fingerprint of `TutorialServiceUnavailable` from the saved response:

```
ALERT_FINGERPRINT=$(printf '%s\n' "$ALERTS_RESPONSE" | jq -r '
  .[] | select(.name == "TutorialServiceUnavailable") | .fingerprint
')
printf '%s\n' "$ALERT_FINGERPRINT"
```{{exec}}

The command should print the fingerprint shown in the short list above. If it prints nothing, allow up to a minute, rerun the alerts request to refresh `ALERTS_RESPONSE`, then repeat the extraction. Continue once a fingerprint appears.

Set its status to `acknowledged`:

```
curl -sS -X POST http://alerting.eoepca.local/v2/alerts/enrich \
  -H 'X-API-KEY: anything' -H 'Content-Type: application/json' \
  -d "{\"fingerprint\":\"$ALERT_FINGERPRINT\",\"enrichments\":{\"status\":\"acknowledged\"}}" | jq
```{{exec}}

```
ALERT_RESPONSE=$(curl -sS "http://alerting.eoepca.local/v2/alerts/$ALERT_FINGERPRINT" \
  -H 'X-API-KEY: anything')
printf '%s\n' "$ALERT_RESPONSE" | jq
```{{exec}}

Show just the status and recovery fields:

```
printf '%s\n' "$ALERT_RESPONSE" | jq '{status, endsAt, unresolvedCounter}'
```{{exec}}

Check for `status: acknowledged` and refresh Keep to see the change. This records that an operator has seen the alert; the service is still stopped.

## Restore the service

```
kubectl -n operations scale deployment/operations-demo --replicas=1
kubectl -n operations rollout status deployment/operations-demo --timeout=120s
curl -sS --retry 5 --retry-connrefused --retry-delay 2 "$DEMO_URL/?request=operations-workshop-recovered"
```{{exec}}

The nginx welcome page should return. Repeat the replica query in Grafana: the value should return to `1`. Find the recovery request in Loki:

```
LOGS_RESPONSE=$(curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" -G \
  "$GRAFANA_URL/api/datasources/proxy/uid/loki/loki/api/v1/query_range" \
  --data-urlencode 'query={namespace="operations", app="operations-demo"} |= "operations-workshop-recovered"')
printf '%s\n' "$LOGS_RESPONSE" | jq
```{{exec}}

Show just the log lines, without the query statistics:

```
printf '%s\n' "$LOGS_RESPONSE" | jq -r '.data.result[].values[][1]'
```{{exec}}

Allow up to a minute for the log to arrive, then rerun the request and short view. Look for `operations-workshop-recovered` with HTTP status `200`. Repeat the `ALERTS` API query from the start of this page; its result should become empty after Prometheus detects recovery.

## Confirm resolution

Recovery is not immediate: allow a minute or two for Prometheus to detect it and Alertmanager to notify Keep. Fetch the latest alert:

```
ALERT_RESPONSE=$(curl -sS "http://alerting.eoepca.local/v2/alerts/$ALERT_FINGERPRINT" \
  -H 'X-API-KEY: anything')
printf '%s\n' "$ALERT_RESPONSE" | jq
```{{exec}}

Show just the status and recovery fields:

```
printf '%s\n' "$ALERT_RESPONSE" | jq '{status, endsAt, unresolvedCounter}'
```{{exec}}

Wait until `endsAt` contains a recovery time and `unresolvedCounter` is `0`. While it is `1`, rerun the request and short view after about 30 seconds. Do not remove the acknowledgement until recovery has arrived.

Keep still displays `acknowledged` because the manual status overrides the source status. Remove the override to show the resolution received from Alertmanager:

```
curl -sS -X POST http://alerting.eoepca.local/v2/alerts/unenrich \
  -H 'X-API-KEY: anything' -H 'Content-Type: application/json' \
  -d "{\"fingerprint\":\"$ALERT_FINGERPRINT\",\"enrichments\":[\"status\"]}" | jq
```{{exec}}

```
ALERT_RESPONSE=$(curl -sS "http://alerting.eoepca.local/v2/alerts/$ALERT_FINGERPRINT" \
  -H 'X-API-KEY: anything')
printf '%s\n' "$ALERT_RESPONSE" | jq
```{{exec}}

Show just the status and recovery fields:

```
printf '%s\n' "$ALERT_RESPONSE" | jq '{status, endsAt, unresolvedCounter}'
```{{exec}}

The short view should now show `status: resolved` and `unresolvedCounter: 0`. If it has not updated, wait a few seconds and rerun the request and short view. Refresh Keep's Feed to see the same status. Leave the service and its rule deployed so you can repeat the exercise.
