## Deploying OpenEO GeoTrellis

With dependencies in place, deploy OpenEO GeoTrellis:

```bash
helm upgrade -i openeo-geotrellis-openeo sparkapplication \
    --repo https://artifactory.vgt.vito.be/artifactory/helm-charts \
    --version 0.16.3 \
    --namespace openeo-geotrellis \
    --create-namespace \
    --values openeo-geotrellis/generated-values.yaml \
    --wait --timeout 10m
```{{exec}}

For Killercoda, deploy the ingress:
```bash
kubectl apply -f openeo-geotrellis/generated-ingress.yaml
source ~/.eoepca/state
export OPENEO_URL="${HTTP_SCHEME}://openeo.${INGRESS_HOST}"
echo "OpenEO API will be accessible at: ${OPENEO_URL}"
```{{exec}}

Wait for the OpenEO GeoTrellis application to be ready:
```bash
kubectl wait --for=condition=Ready --timeout=600s \
    pod -l spark-app-name=openeo-geotrellis-openeo \
    -n openeo-geotrellis
```{{exec}}
