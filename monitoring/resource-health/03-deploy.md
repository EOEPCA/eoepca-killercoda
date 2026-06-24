
We can now deploy the Resource Health building block.

First, create the namespace and apply the Resource Health secrets:

```
bash apply-secrets.sh
```{{exec}}

The Resource Health BB is deployed from the GitHub repository. Let's clone it and update the Helm dependencies:

```
git clone -b 2.0.0 https://github.com/EOEPCA/resource-health.git reference-repo
helm dependency update reference-repo/resource-health-reference-deployment
```{{exec}}

Now deploy the Resource Health BB using the generated values and the
Localcoda-specific compatibility values:

```
helm upgrade -i resource-health reference-repo/resource-health-reference-deployment \
  -f generated-values.yaml \
  -f /tmp/assets/localcoda-values.yaml \
  -n resource-health \
  --timeout 10m
```{{exec}}

The additional values disable an OpenSearch sysctl init container that cannot
change host-level kernel settings from a nested Localcoda container. They also
configure the demo OpenSearch credentials used by the telemetry components.

Create the ingress resources:

```
kubectl apply -f generated-ingress.yaml
```{{exec}}

Wait for OpenSearch and all deployments. This can take a few minutes while
images are downloaded:

```
echo "Waiting for OpenSearch to be ready..."
kubectl rollout status statefulset/resource-health-opensearch \
  -n resource-health --timeout=300s

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
