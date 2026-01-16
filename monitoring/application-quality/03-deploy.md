
We can now deploy the Application Quality building block.

First, create the namespace and apply secrets:

```
bash apply-secrets.sh
```{{exec}}

The Application Quality BB is deployed from its GitHub repository. Clone it and update Helm dependencies:

```
git clone -b reference-deployment https://github.com/EOEPCA/application-quality.git reference-repo
helm dependency update reference-repo/application-quality-reference-deployment
```{{exec}}

Deploy using Helm with the generated values:

```
helm upgrade -i application-quality reference-repo/application-quality-reference-deployment \
  -f generated-values.yaml \
  -n application-quality \
  --timeout 10m
```{{exec}}


Wait for the pods to start. This may take a few minutes in this demo environment:

```
echo "Waiting for Application Quality pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=api -n application-quality --timeout=300s 2>/dev/null || true
kubectl wait --for=condition=ready pod -l app=application-quality-db -n application-quality --timeout=300s 2>/dev/null || true
kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=web -n application-quality --timeout=300s 2>/dev/null || true
```{{exec}}

Check the status of all resources:

```
kubectl get all -n application-quality
```{{exec}}

You should see three main components running:
- **application-quality-api** — The backend API service
- **application-quality-db** — PostgreSQL database
- **application-quality-web** — The frontend web portal

Run the validation script to confirm the deployment:

```
bash validation.sh
```{{exec}}

The web portal should now be accessible at `http://application-quality.eoepca.local`{{}}.

You can also access it from [this link]({{TRAFFIC_HOST1_80}}) (note: some features require OIDC authentication which isn't configured in this demo).