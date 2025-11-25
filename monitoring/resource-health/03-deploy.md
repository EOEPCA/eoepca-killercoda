
We can now deploy the Resource Health building block.

First, we create the namespace:

```
bash apply-secrets.sh
```{{exec}}

The Resource Health BB is deployed from the GitHub repository. Let's clone it and update the Helm dependencies:

```
git clone -b 2.0.0 https://github.com/EOEPCA/resource-health.git reference-repo
helm dependency update reference-repo/resource-health-reference-deployment
```{{exec}}

Now we deploy the Resource Health BB using Helm with our generated values:

```
helm upgrade -i resource-health reference-repo/resource-health-reference-deployment \
  -f generated-values.yaml \
  -n resource-health \
  --timeout 10m
```{{exec}}

And we create the ingress for our newly created Resource Health services to make them available:

```
kubectl apply -f generated-ingress.yaml
```{{exec}}

Now we wait for all Resource Health pods to start. This may take some time, especially in this demo environment. To automatically wait until all services are ready:

```
echo "Waiting for OpenSearch to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=opensearch -n resource-health --timeout=600s 2>/dev/null || true
echo "Waiting for Resource Health pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=resource-health -n resource-health --timeout=600s 2>/dev/null || true
```{{exec}}

Let's check the status of all resources:

```
kubectl get all -n resource-health
```{{exec}}

Once deployed, the Resource Health services should be accessible:
- Web Dashboard: `http://resource-health.eoepca.local`{{}}
- Health Checks API: `http://resource-health.eoepca.local/api/healthchecks/`{{}}
- Telemetry API: `http://resource-health.eoepca.local/api/telemetry/`{{}}

We can validate the deployment using the provided validation script:

```
bash validation.sh
```{{exec}}


You can also access the web dashboard from [this link]({{TRAFFIC_HOST1_80}}) (come back here afterwards, the tutorial is not over).