
## Deploying SharingHub & MLflow

**Update Helm Repositories**:

```bash
curl -L https://github.com/csgroup-oss/sharinghub/archive/refs/tags/0.4.0.tar.gz | tar xvz 
curl -L https://github.com/csgroup-oss/mlflow-sharinghub/archive/refs/tags/0.2.0.tar.gz | tar xvz
```{{exec}}

**Deploy SharingHub**:

```bash
helm upgrade -i sharinghub sharinghub-0.4.0/deploy/helm/sharinghub/ -n sharinghub 
--create-namespace --values sharinghub/generated-values.yaml
```{{exec}}

**Deploy MLflow**:

```bash
rm -rf mlflow-sharinghub-0.2.0
rm -rf sharinghub-0.4.0
apt-get clean
```

```bash
helm dependency build mlflow-sharinghub-0.2.0/deploy/helm/mlflow-sharinghub/
helm upgrade -i mlflow-sharinghub mlflow-sharinghub-0.2.0/deploy/helm/mlflow-sharinghub/ --namespace sharinghub --values mlflow/generated-values.yaml
```{{exec}}

**Create Ingress for MLflow**:

```bash
kubectl apply -f mlflow/generated-ingress.yaml
```{{exec}}