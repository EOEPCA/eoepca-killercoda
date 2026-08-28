
We can now deploy the Resource Health building block.

First, create the namespace and apply the Resource Health secrets:

```
bash apply-secrets.sh
```{{exec}}

The Resource Health BB is deployed from the published EOEPCA Helm charts-dev repository:

```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev/
helm repo update eoepca-dev
```{{exec}}

Now deploy the Resource Health BB using the generated values and the
Localcoda-specific compatibility values:

```
helm upgrade -i resource-health eoepca-dev/resource-health-reference-deployment \
  --version 2.1.1 \
  -f generated-values.yaml \
  -f /tmp/assets/localcoda-values.yaml \
  -n resource-health \
  --create-namespace \
  --timeout 10m
```{{exec}}

The additional values disable an OpenSearch sysctl init container that cannot
change host-level kernel settings from a nested Localcoda container - the
generated values already configure everything else (OpenSearch security,
demo credentials, self-referential API links).

Create the ingress resources:

```
kubectl apply -f generated-ingress.yaml
```{{exec}}

Wait for OpenSearch to be ready, then bootstrap its security configuration -
the chart mounts this config but does not apply it automatically, and the
OpenSearch Dashboards deployment will not become ready until it has:

```
echo "Waiting for OpenSearch to be ready..."
kubectl rollout status statefulset/resource-health-opensearch \
  -n resource-health --timeout=300s

bash bootstrap-opensearch-security.sh
```{{exec}}

Now wait for the remaining deployments (including OpenSearch Dashboards, which
depends on the security bootstrap above) to become ready. This can take a few
minutes while images are downloaded:

```
echo "Waiting for Resource Health deployments to be ready..."
kubectl wait --for=condition=Available deployment --all \
  -n resource-health --timeout=300s
```{{exec}}

Let's check the status of all resources:

```
kubectl get all -n resource-health
```{{exec}}

Once deployed, the services are available through the Localcoda proxy:

- [Resource Health dashboard]({{TRAFFIC_HOST1_81}})
- [Health Checks API documentation]({{TRAFFIC_HOST1_81}}/api/healthchecks/docs)
- [Telemetry API documentation]({{TRAFFIC_HOST1_81}}/api/telemetry/docs)

We can validate the deployment using the provided validation script:

```
bash validation.sh
```{{exec}}
