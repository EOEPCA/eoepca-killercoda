
## Deploying SharingHub & MLflow

Deploy SharingHub:

```bash
helm repo add sharinghub "git+https://github.com/csgroup-oss/sharinghub@deploy/helm?ref=0.4.0"
helm repo update sharinghub
helm upgrade -i sharinghub sharinghub/sharinghub \
  --namespace sharinghub \
  --create-namespace \
  --values sharinghub/generated-values.yaml
```

Deploy MLflow:

```bash
helm repo add mlflow-sharinghub "git+https://github.com/csgroup-oss/mlflow-sharinghub@deploy/helm?ref=0.2.0"
helm repo update mlflow-sharinghub
helm upgrade -i mlflow-sharinghub mlflow-sharinghub/mlflow-sharinghub \
  --namespace sharinghub \
  --create-namespace \
  --values mlflow/generated-values.yaml
```
