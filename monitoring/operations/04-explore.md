With Operations deployed, let's explore what it collects.

## Log in to Grafana

Without IAM enabled, Grafana uses local admin auth. Retrieve the chart-generated credentials:

```
kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-user}' | base64 -d; echo
kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo
```{{exec}}

Open Grafana and log in with those credentials:

[Open Grafana]({{TRAFFIC_HOST1_81}})

## Verify the datasources

Navigate to `Connections → Data sources` and confirm both **Prometheus** (default) and **Loki** are configured, then test each one from the UI.

## Explore logs

Open the **Explore** tab, select the **Loki** datasource, and run a query for the Operations namespace itself:

```logql
{namespace="operations"}
```

You should see log lines from the Operations BB's own components. That confirms the Alloy → Loki pipeline is working end to end.

## Load a curated dashboard

Navigate to `Dashboards → Browse` and open the **Kubernetes / Cluster View** dashboard. It should populate with live data from the cluster within a few refreshes.

The **APISIX Endpoint SLOs** dashboard (built from STAC-specific recording rules, despite the name on the underlying file) is also listed, but its panels stay empty here. It only has data once Data Access is deployed with STAC alerts enabled.

## Trigger a test alert

The baseline rules include a `Watchdog` alert, which fires continuously as a pipeline health check. Confirm it has reached Keep:

```
curl -s "http://alerting.eoepca.local/v2/alerts" -H "Accept: application/json" -H "X-API-KEY: anything" | grep -o '"name":"Watchdog"'
```{{exec}}

> Even with `AUTH_TYPE=NO_AUTH`, Keep's API still requires an `X-API-KEY` header to be present, it just doesn't validate its value. A request with no key at all is rejected with `401 Missing API Key`.

You can also open Keep directly and see the same alert in the UI:

[Open Keep]({{TRAFFIC_HOST1_82}})

## Verify Alertmanager routing

Confirm Alertmanager's configuration has loaded the receiver defined by our `AlertmanagerConfig`, which is what forwards alerts to Keep via the relay. Prometheus Operator namespaces receivers from `AlertmanagerConfig` CRDs as `<namespace>/<object-name>/<receiver-name>`, so our `keep` receiver in the `keep` object shows up as `operations/keep/keep`:

```
kubectl -n operations exec alertmanager-kube-prometheus-stack-alertmanager-0 -- \
  wget -qO- http://localhost:9093/api/v2/status | grep -o 'operations/keep/keep'
```{{exec}}
