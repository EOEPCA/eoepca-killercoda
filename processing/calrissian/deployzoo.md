ZOO-Project exposes the OGC API Processes interface. When a processing request arrives, it starts Calrissian to run the application on Kubernetes.

Add the Helm repository:

```
helm repo add zoo-project https://zoo-project.github.io/charts/
helm repo update zoo-project
```{{exec}}

Install the chart with the generated values:

```
helm upgrade -i zoo-project-dru zoo-project/zoo-project-dru \
  --version 0.10.3 \
  --values generated-values.yaml \
  --namespace processing \
  --create-namespace
```{{exec}}

Wait for the pods to become ready:

```
kubectl -n processing wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

Run the deployment guide validation:

```
bash validation.sh
```{{exec}}

List the built-in processes:

```
curl -sS http://zoo.eoepca.local/ogc-api/processes/ | jq
```{{exec}}

The response includes the sample `echo` process. You can also explore the API in the [Swagger UI]({{TRAFFIC_HOST1_81}}/swagger-ui/oapip/).
