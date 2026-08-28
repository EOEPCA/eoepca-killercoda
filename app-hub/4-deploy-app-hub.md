
## Deploy the Application Hub

With the Keycloak client in place, apply the secret the Helm release needs:

```bash
bash apply-secrets.sh
```{{exec}}

Add the EOEPCA Helm repository:

```bash
helm repo add eoepca https://eoepca.github.io/helm-charts
helm repo update eoepca
```{{exec}}

Deploy the Application Hub:

```bash
helm upgrade -i application-hub eoepca/application-hub \
  --version 2.1.0 \
  --values generated-values.yaml \
  --namespace app-hub \
  --create-namespace
```{{exec}}

Apply the ingress configuration:

```bash
kubectl apply -f generated-ingress.yaml
```{{exec}}

Wait for the Application Hub pods to be ready:

```bash
kubectl wait --for=condition=Ready --all=true -n app-hub pod --timeout=5m
```{{exec}}

Check the deployment status:

```bash
kubectl get pods -n app-hub
```{{exec}}

You should see the JupyterHub hub, proxy, and related components in `Running` state.
