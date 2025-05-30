
## Deploying SharingHub & MLflow

Deploy SharingHub:

```bash
helm upgrade -i sharinghub sharinghub/sharinghub \
  --namespace sharinghub --create-namespace \
  --values sharinghub/generated-values.yaml
```
  
```bash
kubectl apply -f sharinghub/generated-ingress.yaml
```

Deploy MLflow:

```bash
helm upgrade -i mlflow-sharinghub mlflow-sharinghub/mlflow-sharinghub \
  --namespace sharinghub \
  --values mlflow/generated-values.yaml
```


```bash
kubectl apply -f mlflow/generated-ingress.yaml
```