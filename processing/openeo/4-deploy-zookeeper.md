## Deploying ZooKeeper

Apache ZooKeeper is required for internal coordination within the OpenEO Geotrellis components.

Deploy ZooKeeper using the following Helm command:

```bash
helm upgrade -i openeo-geotrellis-zookeeper \
    https://artifactory.vgt.vito.be/artifactory/helm-charts/zookeeper-11.1.6.tgz \
    --namespace openeo-geotrellis \
    --create-namespace \
    --values zookeeper/generated-values.yaml
```{{exec}}

You must wait for the ZooKeeper deployment to be fully running before proceeding. You can check the status of the pods with `kubectl get pods -n openeo-geotrellis`.
