
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
  --version 2.1.3 \
  -f generated-values.yaml \
  -f /tmp/assets/localcoda-values.yaml \
  -n resource-health --create-namespace
```{{exec}}

The additional values disable the OpenSearch sysctl init container because
Localcoda cannot change host kernel settings.

Wait for OpenSearch and the remaining deployments. OpenSearch initialises its
security configuration automatically on a fresh data volume:

```
kubectl rollout status statefulset/resource-health-opensearch \
  -n resource-health --timeout=300s
kubectl wait --for=condition=Available deployment --all \
  -n resource-health --timeout=300s
```{{exec}}

Create the ingress resources:

```
kubectl apply -f generated-ingress.yaml
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
