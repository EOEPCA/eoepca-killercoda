Use a small web service to follow an outage through metrics, logs and alert triage. The service represents a platform endpoint; it does not deploy another building block.

## Log in to Grafana

Retrieve the chart-generated credentials:

```
kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-user}' | base64 -d; echo
kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo
```{{exec}}

For the API examples below, use the same Grafana credentials:

```
GRAFANA_USER=$(kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-user}' | base64 -d)
GRAFANA_PASSWORD=$(kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d)
GRAFANA_URL=http://monitoring.eoepca.local
```{{exec}}

## Create a monitored service

Inspect the sample Deployment, Service and PrometheusRule:

```
cat /tmp/assets/operations-demo.yaml
```{{exec}}

The rule fires when the web service has no available replicas for one minute. Its metric comes from kube-state-metrics, which observes Kubernetes workloads.

```
kubectl apply -f /tmp/assets/operations-demo.yaml
kubectl -n operations rollout status deployment/operations-demo --timeout=120s
DEMO_URL=http://$(kubectl -n operations get service operations-demo -o jsonpath='{.spec.clusterIP}')
curl -sS "$DEMO_URL/?request=operations-workshop"
```{{exec}}

You should see the nginx welcome page. If you don't, wait 10 seconds and try again.

## Inspect its metrics and logs

In Grafana **Explore**, select **Prometheus** and run:

```promql
kube_deployment_status_replicas_available{namespace="operations", deployment="operations-demo"}
```

The value should be `1`. Allow up to a minute for the first scrape. You can query the same datasource through Grafana's API:

```
curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" -G \
  "$GRAFANA_URL/api/datasources/proxy/uid/prometheus/api/v1/query" \
  --data-urlencode 'query=kube_deployment_status_replicas_available{namespace="operations", deployment="operations-demo"}' | jq
```{{exec}}

Switch Explore to **Loki** and run:

```logql
{namespace="operations", app="operations-demo"} |= "operations-workshop"
```

Find the request with HTTP status `200`. Alloy has collected the pod's access log and sent it to Loki. The API equivalent is:

```
curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" -G \
  "$GRAFANA_URL/api/datasources/proxy/uid/loki/loki/api/v1/query_range" \
  --data-urlencode 'query={namespace="operations", app="operations-demo"} |= "operations-workshop"' | jq
```{{exec}}

If either response is empty, run it again after a few seconds.

Open **Dashboards → Kubernetes / Cluster View** to see cluster resource use. **Kubernetes / Workload View** lets you select namespace `operations` and the `operations-demo` pod. CPU rates need several scrapes before they appear. CPU limit panels are empty for workloads without CPU limits. Localcoda reduces pod resource requests to fit the tutorial environment, so usage-to-request percentages can exceed 100%.

The **APISIX Endpoint SLOs** dashboard needs Data Access metrics and STAC recording rules, which this tutorial does not deploy.

## Cause an outage

Stop the sample service:

```
kubectl -n operations scale deployment/operations-demo --replicas=0
```{{exec}}

Repeat the Prometheus query above: available replicas should fall to `0`. Query the alert state:

```
curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" -G \
  "$GRAFANA_URL/api/datasources/proxy/uid/prometheus/api/v1/query" \
  --data-urlencode 'query=ALERTS{alertname="TutorialServiceUnavailable"}' | jq
```{{exec}}

The `alertstate` label changes from `pending` to `firing` after one minute. Allow another minute for scraping, rule evaluation and Alertmanager delivery.

## Triage in Keep

[Open Keep]({{TRAFFIC_HOST1_82}}) and select **Alerts → Feed**. Find **TutorialServiceUnavailable** in the list. **Watchdog** should also be present as the continuous pipeline health check.

```
curl -sS http://alerting.eoepca.local/v2/alerts \
  -H 'X-API-KEY: anything' | jq
```{{exec}}

Find `TutorialServiceUnavailable` and copy its `fingerprint` from the response:

```
read -r -p 'Alert fingerprint: ' ALERT_FINGERPRINT
```{{exec}}

Keep's unauthenticated mode still requires the API-key header, but accepts any value. Acknowledge the alert:

```
curl -sS -X POST http://alerting.eoepca.local/v2/alerts/enrich \
  -H 'X-API-KEY: anything' -H 'Content-Type: application/json' \
  -d "{\"fingerprint\":\"$ALERT_FINGERPRINT\",\"enrichments\":{\"status\":\"acknowledged\"}}" | jq
```{{exec}}

```
curl -sS "http://alerting.eoepca.local/v2/alerts/$ALERT_FINGERPRINT" \
  -H 'X-API-KEY: anything' | jq
```{{exec}}

Check for `status: acknowledged` in the response and refresh Keep to see the same status. Acknowledgement records that an operator has seen the problem; it does not restore the service.

## Restore the service

```
kubectl -n operations scale deployment/operations-demo --replicas=1
kubectl -n operations rollout status deployment/operations-demo --timeout=120s
curl -sS "$DEMO_URL/?request=operations-workshop-recovered"
```{{exec}}

Repeat the metrics and logs queries. Available replicas should return to `1`, and Loki should contain the recovery request. The `ALERTS` query should become empty once Prometheus evaluates the recovered state.

After Alertmanager delivers the recovery, check the alert again:

```
curl -sS "http://alerting.eoepca.local/v2/alerts/$ALERT_FINGERPRINT" \
  -H 'X-API-KEY: anything' | jq
```{{exec}}

Check that `endsAt` contains the recovery time and `unresolvedCounter` is `0`. Keep retains the manual acknowledgement as a status override even after receiving the resolution. Remove that override to display the source status:

```
curl -sS -X POST http://alerting.eoepca.local/v2/alerts/unenrich \
  -H 'X-API-KEY: anything' -H 'Content-Type: application/json' \
  -d "{\"fingerprint\":\"$ALERT_FINGERPRINT\",\"enrichments\":[\"status\"]}" | jq
```{{exec}}

```
curl -sS "http://alerting.eoepca.local/v2/alerts/$ALERT_FINGERPRINT" \
  -H 'X-API-KEY: anything' | jq
```{{exec}}

Confirm `status: resolved` and refresh Keep's Feed to see the resolved alert. The service and its rule remain deployed so you can repeat the exercise.
