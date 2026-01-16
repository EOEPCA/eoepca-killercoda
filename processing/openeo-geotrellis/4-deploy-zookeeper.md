[Apache ZooKeeper](https://zookeeper.apache.org/) is required for coordination within the OpenEO GeoTrellis components.

We can deploy ZooKeeper using Helm:

```bash
helm upgrade -i openeo-geotrellis-zookeeper \
    https://artifactory.vgt.vito.be/artifactory/helm-charts/zookeeper-11.1.6.tgz \
    --namespace openeo-geotrellis \
    --values zookeeper/generated-values.yaml \
    --set image.registry=docker.io \
    --set image.repository=bitnamilegacy/zookeeper \
    --set image.tag=3.8.1-debian-11-r18 \
    --wait --timeout 5m
```{{exec}}
