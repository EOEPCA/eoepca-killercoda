
## Deploy the Application Hub

With the Keycloak client in place, we can now deploy the Application Hub using Helm.

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
  --namespace application-hub \
  --create-namespace
```{{exec}}

Apply the ingress configuration:

```bash
kubectl apply -f generated-ingress.yaml
```{{exec}}

Wait for the Application Hub pods to be ready:

```bash
kubectl wait --for=condition=Ready --all=true -n application-hub pod --timeout=5m
```{{exec}}

Check the deployment status:

```bash
kubectl get pods -n application-hub
```{{exec}}

You should see the JupyterHub hub, proxy, and related components in `Running` state.

Then visit the [Application Hub]({{TRAFFIC_HOST1_83}}/) of the deployed service.