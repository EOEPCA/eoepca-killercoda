[Apache ZooKeeper](https://zookeeper.apache.org/) provides coordination for the OpenEO GeoTrellis components. The generated values create one ZooKeeper replica with persistent storage, which is sufficient for this workshop but not a production high-availability setup.

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

The command should finish with `STATUS: deployed`. Helm may also print optional `zkCli.sh` connection instructions; no additional action is needed.
