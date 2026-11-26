OpenEO GeoTrellis runs processing workloads with Apache Spark. The [Spark Operator](https://github.com/kubeflow/spark-operator) adds the Kubernetes resources and controllers needed to manage those Spark applications.

Install the operator using its generated values. Helm waits up to five minutes for the controller and webhook to become ready:

```bash
helm upgrade -i openeo-geotrellis-sparkoperator spark-operator \
    --repo https://kubeflow.github.io/spark-operator \
    --version 2.3.0 \
    --namespace openeo-geotrellis \
    --create-namespace \
    --values sparkoperator/generated-values.yaml \
    --wait --timeout 5m
```{{exec}}

The command should finish with `STATUS: deployed`.
