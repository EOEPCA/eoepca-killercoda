
## Deploy Ingress and Authentication

### Apply Ingress

```bash
kubectl apply -f generated-ingress.yaml
```{{exec}}

### Deploy Authentication Proxy

```bash
kubectl apply -f generated-proxy-auth.yaml
```{{exec}}

### Set Up Mock OIDC Provider

```bash
bash /tmp/assets/mock-oidc-setup
```{{exec}}

### Configure Demo Authentication

```bash
bash /tmp/assets/setup-demo-auth
```{{exec}}

### Verify Components

```bash
kubectl get pods -n openeo
kubectl get ingress -n openeo
```{{exec}}

### Test API Access

```bash
curl -u eoepcauser:eoepcapass http://openeo.eoepca.local/
```{{exec}}

You should see a JSON response with API version and endpoint information.