With dependencies in place, we can now deploy OpenEO GeoTrellis:

First, prepare a Localcoda-compatible copy of the OpenEO GeoTrellis image. This keeps the deployment guide output unchanged, but rewrites one small image layer locally so k3s can unpack it inside the Localcoda user namespace.

```bash
/tmp/assets/patch-openeo-geotrellis-image
```{{exec}}

```bash
helm upgrade -i openeo-geotrellis-openeo sparkapplication \
    --repo https://artifactory.vgt.vito.be/artifactory/helm-charts \
    --version 1.0.2 \
    --namespace openeo-geotrellis \
    --create-namespace \
    --values openeo-geotrellis/generated-values.yaml \
    --set imageVersion=localcoda \
    --set imagePullPolicy=IfNotPresent
```{{exec}}

And then, to make it accessible, deploy the ingress:

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


Our local OpenEO APIs will now be accessible in the sandbox environment at `http://openeo.eoepca.local/`{{}}

You can also access it over ingress at [this link]({{TRAFFIC_HOST1_81}}) (it may take a minute after the deployment for the ingress to be fully ready).
