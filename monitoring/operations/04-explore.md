With Operations deployed, let's explore what it collects.

## Log in to Grafana

Without IAM enabled, Grafana uses local admin auth. Retrieve the chart-generated credentials:

```
kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-user}' | base64 -d; echo
kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo
```{{exec}}

[Open Grafana]({{TRAFFIC_HOST1_81}})

## Verify the datasources

`Connections → Data sources`: confirm **Prometheus** (default) and **Loki** are configured, and test each.

## Explore metrics

**Explore** tab → **Prometheus**:

```promql
up{namespace="operations"}
```

One result per scrape target in the namespace, all `1` — Prometheus is scraping the whole stack.

## Explore logs

**Explore** tab → **Loki**:

```logql
{namespace="operations"}
```

Log lines from the Operations BB's own components — the Alloy → Loki pipeline is working.

## Load a curated dashboard

`Dashboards → Browse` → **Kubernetes / Cluster View**. It populates with live cluster data.

The **APISIX Endpoint SLOs** dashboard is also listed but stays empty here — it only has data once Data Access is deployed with STAC alerts enabled.

## The pipeline in action

The baseline rules include a `Watchdog` alert, firing continuously as a health check — proof the real Prometheus → Alertmanager → Keep pipeline is delivering on its own, with no one triggering it:

```
curl -s "http://alerting.eoepca.local/v2/alerts" -H "Accept: application/json" -H "X-API-KEY: anything" | grep -o '"name":"Watchdog"'
```{{exec}}

## Trigger and triage an alert

Now simulate one yourself, as if it came from a monitored service:

```
curl -s -X POST "http://alerting.eoepca.local/v2/alerts/event?fingerprint=tutorial-demo-alert" \
  -H "X-API-KEY: anything" -H "Content-Type: application/json" \
  -d '{"name":"DataAccessLatencyHigh","status":"firing","severity":"warning","lastReceived":"'"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"'"}'
```{{exec}}

Confirm it's firing in Keep:

```
curl -s "http://alerting.eoepca.local/v2/alerts/tutorial-demo-alert" -H "X-API-KEY: anything" | grep -o '"status":"firing"'
```{{exec}}

> Even with `AUTH_TYPE=NO_AUTH`, Keep still requires an `X-API-KEY` header — it just doesn't check its value.

[Open Keep]({{TRAFFIC_HOST1_82}}) — the alert is in the list.

Acknowledge it, same as a user would from the UI:

```
curl -s -X POST "http://alerting.eoepca.local/v2/alerts/enrich" \
  -H "X-API-KEY: anything" -H "Content-Type: application/json" \
  -d '{"fingerprint":"tutorial-demo-alert","enrichments":{"status":"acknowledged"}}'
```{{exec}}

```
curl -s "http://alerting.eoepca.local/v2/alerts/tutorial-demo-alert" -H "X-API-KEY: anything" | grep -o '"status":"acknowledged"'
```{{exec}}
