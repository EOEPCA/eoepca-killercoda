## Deploying ZooKeeper

Apache ZooKeeper is required for coordination within the OpenEO GeoTrellis components.

Deploy ZooKeeper using Helm:

```bash
helm upgrade -i openeo-geotrellis-zookeeper \
    https://artifactory.vgt.vito.be/artifactory/helm-charts/zookeeper-11.1.6.tgz \
    --namespace openeo-geotrellis \
    --create-namespace \
    --values zookeeper/generated-values.yaml \
    --wait --timeout 5m
```{{exec}}
