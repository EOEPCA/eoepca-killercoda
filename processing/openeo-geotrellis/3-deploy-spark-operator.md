The OpenEO GeoTrellis engine requires Apache Spark for processing. This is instantiated bia the [Spark Operator](https://github.com/kubeflow/spark-operator). We can deploy it via:

```bash
helm upgrade -i openeo-geotrellis-sparkoperator spark-operator \
    --repo https://artifactory.vgt.vito.be/artifactory/helm-charts \
    --version 2.0.2 \
    --namespace openeo-geotrellis \
    --create-namespace \
    --values sparkoperator/generated-values.yaml \
    --wait --timeout 5m
```{{exec}}
