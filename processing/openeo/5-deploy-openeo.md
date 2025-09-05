With dependencies in place, we can now deploy OpenEO GeoTrellis:

```bash
helm upgrade -i openeo-geotrellis-openeo sparkapplication \
    --repo https://artifactory.vgt.vito.be/artifactory/helm-charts \
    --version 0.16.3 \
    --namespace openeo-geotrellis \
    --create-namespace \
    --values openeo-geotrellis/generated-values.yaml \
    --wait --timeout 10m
```{{exec}}

An then, to make it accessible, deploy the ingress:

```bash
kubectl apply -f openeo-geotrellis/generated-ingress.yaml
```{{exec}}

Wait for the OpenEO GeoTrellis application to be ready:
```bash
kubectl wait --for=condition=Ready --timeout=600s \
    pod -l spark-app-name=openeo-geotrellis-openeo \
    -n openeo-geotrellis
```{{exec}}

we can now see that all the pods are running correctly via

```
kubectl get pods -n openeo-geotrellis
```{{exec}}

We will see the pods for:
- Spark Operator controller and webhook
- ZooKeeper
- OpenEO driver and executor


Our local OpenEO APIs will be now accessible in the sandbox environment at `http://openeo.eoepca.local/`{{}}
