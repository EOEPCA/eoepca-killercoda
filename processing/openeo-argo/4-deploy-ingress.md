## Deploy Ingress

Create and apply the ingress configuration for HTTP access:

```bash
kubectl apply -f generated-ingress.yaml
```{{exec}}

Set up the OpenEO URL:

```bash
source ~/.eoepca/state
echo "OpenEO ArgoWorkflows API: ${OPENEO_URL}"
```{{exec}}

For Killercoda port forwarding (backup access method):

```bash
kubectl port-forward -n openeo svc/openeo-api 8080:8080 --address=0.0.0.0 &
echo "Direct access available at: http://localhost:8080"
```{{exec}}