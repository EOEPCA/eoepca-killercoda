With dependencies in place, we can now deploy OpenEO GeoTrellis:

First, prepare a Localcoda-compatible copy of the OpenEO GeoTrellis image. This keeps the Deployment Guide output unchanged, but rewrites one small image layer locally so k3s can unpack it inside the Localcoda user namespace.

This one-time preparation downloads a large image and normally takes one or two minutes. Wait for the `Patched OpenEO GeoTrellis image ready` message before continuing:

```bash
/tmp/assets/patch-openeo-geotrellis-image
```{{exec}}

Install the OpenEO Spark application. The two overrides select the locally patched image and prevent Kubernetes from replacing it with a remote pull:

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

This Helm chart creates a `SparkApplication` custom resource, so Helm can return before its driver pod exists. Create the Ingress while the Spark Operator starts the application:

```bash
kubectl apply -f openeo-geotrellis/generated-ingress.yaml
```{{exec}}

First wait for the Spark Operator to create the driver pod:

```bash
kubectl wait --for=create --timeout=600s \
    pod -l spark-role=driver \
    -n openeo-geotrellis
```{{exec}}

Then wait for the driver container to become Kubernetes-ready:

```bash
kubectl wait --for=condition=Ready --timeout=600s \
    pod -l spark-role=driver \
    -n openeo-geotrellis
```{{exec}}

The pod can become Kubernetes-ready shortly before the OpenEO HTTP server starts accepting requests. Use this bounded check to wait up to five more minutes for the API:

```bash
for attempt in $(seq 1 20); do
  if curl -fsS http://openeo.eoepca.local/openeo/1.2/ \
      >/dev/null 2>&1; then
    echo "OpenEO API is ready."
    break
  fi

  if [ "${attempt}" -eq 20 ]; then
    echo "OpenEO API did not become ready in time." >&2
    kubectl logs -n openeo-geotrellis \
      -l spark-role=driver --tail=50
    exit 1
  fi

  echo "OpenEO API is still starting (${attempt}/20)..."
  sleep 15
done
```{{exec}}

Display the completed deployment:

```bash
kubectl get pods -n openeo-geotrellis
```{{exec}}

You should see five running pods:

- Spark Operator controller and webhook
- ZooKeeper
- OpenEO driver and executor

The OpenEO API is now available inside the sandbox at `http://openeo.eoepca.local/`.

The Localcoda proxy exposes the same API over HTTPS at [this public URL]({{TRAFFIC_HOST1_81}}). Opening it in a browser redirects to the OpenEO 1.2 capabilities document.
