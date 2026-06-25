## Deploy Ingress and Demo Authentication

Apply the generated ingress:

```bash
kubectl apply -f generated-ingress.yaml
```{{exec}}

The OpenEO API validates OIDC bearer tokens internally. For this self-contained workshop, deploy a minimal in-cluster OIDC provider and a basic-auth ingress proxy that exchanges the workshop credentials for a signed demo token:

```bash
bash /tmp/assets/mock-oidc-setup
bash /tmp/assets/setup-demo-auth
```{{exec}}

Check the components:

```bash
kubectl get pods -n openeo
kubectl get ingress -n openeo
```{{exec}}

The proxy may briefly return `502` while NGINX resolves the newly rolled-out backend. Use this bounded check to verify the API:

```bash
for attempt in $(seq 1 12); do
  if response=$(curl -fsS -u eoepcauser:eoepcapass \
      http://openeo.eoepca.local/); then
    jq '{title, api_version, backend_version}' <<<"${response}"
    break
  fi
  echo "API not ready yet (attempt ${attempt}/12)"
  sleep 5
done
```{{exec}}

The OpenEO ingress is also available through the Localcoda proxy at [this link]({{TRAFFIC_HOST1_81}}).
