## Deploying the Spark Operator

The OpenEO Geotrellis engine relies on Apache Spark for processing. The Kubeflow Spark Operator is used to manage Spark jobs within our Kubernetes cluster.

Let's deploy the Spark Operator using Helm:

```bash
helm upgrade -i openeo-geotrellis-sparkoperator spark-operator \
    --repo https://artifactory.vgt.vito.be/artifactory/helm-charts \
    --version 2.0.2 \
    --namespace openeo-geotrellis \
    --create-namespace \
    --values sparkoperator/generated-values.yaml
```{{exec}}

```bash
crictl rmi --prune
```{{exec}}

This command will install the Spark Operator into the `openeo-geotrellis` namespace.