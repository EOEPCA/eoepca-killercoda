## Deploying OpenEO Geotrellis

With the dependencies in place, we can now deploy OpenEO Geotrellis. This component provides the API that connects users to the Earth observation cloud back-ends.

```bash
helm upgrade -i openeo-geotrellis-openeo sparkapplication \
    --repo https://artifactory.vgt.vito.be/artifactory/helm-charts \
    --version 0.16.3 \
    --namespace openeo-geotrellis \
    --create-namespace \
    --values openeo-geotrellis/generated-values.yaml
```{{exec}}

Next, deploy the ingress to expose the OpenEO service:

```bash
kubectl apply -f openeo-geotrellis/generated-ingress.yaml
```{{exec}}

This makes the OpenEO API accessible through your configured ingress host.
