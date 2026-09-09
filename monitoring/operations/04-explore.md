Deploy a small nginx service, check its replica count in Prometheus and find its request logs in Loki. The next page uses this service to demonstrate alert handling.

## Log in to Grafana

[Open Grafana]({{TRAFFIC_HOST1_81}}) and log in with the credentials stored in this Kubernetes Secret:

```
kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-user}' | base64 -d; echo
kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d; echo
```{{exec}}

Store the credentials and URL for the API commands on this page and the next:

```
GRAFANA_USER=$(kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-user}' | base64 -d)
GRAFANA_PASSWORD=$(kubectl -n operations get secret kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d)
GRAFANA_URL=http://monitoring.eoepca.local
```{{exec}}

## Create a monitored service

Inspect the manifest. It defines an nginx Deployment, a Service and an alert rule:

```
cat /tmp/assets/operations-demo.yaml
```{{exec}}

The alert rule uses kube-state-metrics to detect when the Deployment has no available replicas for one minute. First, deploy the service and send an HTTP request:

```
kubectl apply -f /tmp/assets/operations-demo.yaml
kubectl -n operations rollout status deployment/operations-demo --timeout=120s
DEMO_URL=http://$(kubectl -n operations get service operations-demo -o jsonpath='{.spec.clusterIP}')
curl -sS --retry 5 --retry-connrefused --retry-delay 2 "$DEMO_URL/?request=operations-workshop"
```{{exec}}

You should see the nginx welcome page. The request retries briefly while Kubernetes updates the service route.

## Check the replica count

In Grafana **Explore**, select the **Prometheus** datasource, then **Code** on the top right next to _Builder_ and run:

```promql
kube_deployment_status_replicas_available{namespace="operations", deployment="operations-demo"}
```

The value should be `1`: one replica is available. Allow up to a minute for Prometheus to scrape the metric. To see the same result in the terminal, use Grafana's datasource API:

```
METRICS_RESPONSE=$(curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" -G \
  "$GRAFANA_URL/api/datasources/proxy/uid/prometheus/api/v1/query" \
  --data-urlencode 'query=kube_deployment_status_replicas_available{namespace="operations", deployment="operations-demo"}')
printf '%s\n' "$METRICS_RESPONSE" | jq
```{{exec}}

Show just the available replica count:

```
printf '%s\n' "$METRICS_RESPONSE" | jq -r '.data.result[].value[1]'
```{{exec}}

If no count appears yet, wait up to a minute and rerun the request above. The `jq` command only reads the saved response; it does not fetch new data.

## Find the request log

In Grafana **Explore**, select **Loki** and run:

```logql
{namespace="operations", app="operations-demo"} |= "operations-workshop"
```

Look for `operations-workshop` and HTTP status `200`. This confirms that Alloy collected nginx's access log and sent it to Loki. The same query is available through the API:

```
LOGS_RESPONSE=$(curl -sS -u "$GRAFANA_USER:$GRAFANA_PASSWORD" -G \
  "$GRAFANA_URL/api/datasources/proxy/uid/loki/loki/api/v1/query_range" \
  --data-urlencode 'query={namespace="operations", app="operations-demo"} |= "operations-workshop"')
printf '%s\n' "$LOGS_RESPONSE" | jq
```{{exec}}

Show just the log lines, without the query statistics:

```
printf '%s\n' "$LOGS_RESPONSE" | jq -r '.data.result[].values[][1]'
```{{exec}}

Logs can take up to a minute to appear. Rerun the request to refresh `LOGS_RESPONSE`, then display the log lines again.

## View resource use

Open these Grafana dashboards:

- **Kubernetes / Cluster View** shows cluster CPU and memory use.
- **Kubernetes / Workload View** shows individual pods. Select namespace `operations` and the pod whose name starts with `operations-demo`.

CPU rates need several scrapes before they appear. CPU limit panels are empty because the sample has no CPU limit. Localcoda reduces resource requests, so usage-to-request percentages can exceed 100%.

The **APISIX Endpoint SLOs** dashboard stays empty: this tutorial does not deploy the Data Access metrics and STAC rules it needs.

Leave the service running and keep this terminal open. The next page uses the same shell variables to trigger an outage and follow its alert through to recovery.
