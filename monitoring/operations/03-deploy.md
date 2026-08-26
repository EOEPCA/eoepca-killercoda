We can now deploy the Operations building block.

First, create the namespace and apply the secrets it needs — the Loki S3 credentials and the Keep auth placeholder:

```
bash apply-secrets.sh
```{{exec}}

### Deploy kube-prometheus-stack

The core monitoring stack is deployed first so that its CRDs (`ServiceMonitor`, `PrometheusRule`, `AlertmanagerConfig`) are available for the components that follow. This is the biggest image pull in this tutorial, so it can take a few minutes:

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community
helm upgrade -i kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --version 83.1.0 \
  --namespace operations \
  --create-namespace \
  --values kube-prometheus-stack/generated-values.yaml \
  --wait --timeout 5m
```{{exec}}

### Deploy Loki

```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana
helm upgrade -i loki grafana/loki \
  --version 6.55.0 \
  --namespace operations \
  --values loki/generated-values.yaml \
  --set loki.storage.s3.insecure=true \
  --wait --timeout 5m
```{{exec}}

> The deployment guide's own `values-template.yaml` assumes a real S3 endpoint behind TLS, as it would be in a production deployment. The tutorial's local MinIO is plain HTTP, so this step adds `--set loki.storage.s3.insecure=true` on top of the generated values to match — a tutorial-only override, not a guide fix.

### Deploy Alloy

Alloy is deployed as raw manifests rather than via Helm, since its configuration is tightly coupled to the cluster's log paths and the Loki endpoint:

```
kubectl apply -k alloy/
```{{exec}}

### Deploy Keep

Keep is the alert triage UI. Without IAM enabled, it runs unauthenticated:

```
source ~/.eoepca/state
helm repo add keephq https://keephq.github.io/helm-charts
helm repo update keephq

helm upgrade -i keep keephq/keep \
  --version 0.1.95 \
  --namespace operations \
  --values keep/generated-values.yaml \
  --wait --timeout 5m
```{{exec}}

### Apply the alerting configuration

This deploys the Alertmanager-to-Keep relay, the `AlertmanagerConfig` routing rules, and the baseline `PrometheusRule`s (STAC alerts are skipped, since we didn't enable them):

```
kubectl apply -f alerting/generated-keep-alertmanager-relay.yaml
kubectl apply -f alerting/generated-alertmanagerconfig.yaml
kubectl apply -f rules/baseline-alerts.yaml
```{{exec}}

### Apply the Grafana dashboards

Dashboards are delivered as labelled ConfigMaps which Grafana's sidecar discovers and loads automatically:

```
kubectl apply -k dashboards/
```{{exec}}

### Configure the ingress routes

```
source ~/.eoepca/state
kubectl apply -f ingress/generated-monitoring-ingress.yaml
kubectl apply -f ingress/generated-alerting-ingress.yaml
```{{exec}}

### Check the deployment

Wait for the workloads to become ready:

```
kubectl wait --for=condition=available deployment --all -n operations --timeout=300s
kubectl rollout status daemonset/alloy-logs -n operations --timeout=300s
```{{exec}}

```
kubectl get all -n operations
```{{exec}}

Run the validation script to confirm everything is in place:

```
bash validation.sh
```{{exec}}

Grafana and Keep are now available through the Localcoda proxy:

- [Grafana]({{TRAFFIC_HOST1_81}})
- [Keep]({{TRAFFIC_HOST1_82}})
