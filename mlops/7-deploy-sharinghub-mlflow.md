It is now time to deploy the SharingHub and the MLFlow application, to do so, we need first to download locally their helm charts, via

```bash
curl -L https://github.com/csgroup-oss/sharinghub/archive/refs/tags/0.4.0.tar.gz | tar xvz 
curl -L https://github.com/csgroup-oss/mlflow-sharinghub/archive/refs/tags/0.2.0.tar.gz | tar xvz
```{{exec}}

Then we can deploy the SharingHub with the genrated configuration values via

```bash
helm upgrade -i sharinghub sharinghub-0.4.0/deploy/helm/sharinghub/ -n sharinghub \
--create-namespace --values sharinghub/generated-values.yaml
```{{exec}}

and deploy MLflow. Note that we will disable the Postgres database deployed with MLFlow for performance reasons, using the `--set postgresql.enabled=false`{{}}. This is not suggested in production

```bash
helm upgrade -i mlflow-sharinghub mlflow-sharinghub-0.2.0/deploy/helm/mlflow-sharinghub/ --namespace sharinghub --values mlflow/generated-values.yaml --set postgresql.enabled=false
```{{exec}}


Now we need to create the ingress for mlflow

```

```{{exec}}

Let's wait for the container to start with

```
kubectl -n processing wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

At last, we need to create the ingresses

```bash
kubectl apply -f sharinghub/generated-ingress.yaml
kubectl apply -f mlflow/generated-ingress.yaml
```{{exec}}


**Create Ingress for MLflow**:

```bash
kubectl apply -f mlflow/generated-ingress.yaml
```{{exec}}

**Turn GitLab back on**:

```bash
docker start $(docker ps -qaf "name=gitlab")
```{{exec}}

Now you must wait for GitLab to start up. This can take a few minutes. 

Confirm that you can:
- [Visit GitLab]({{TRAFFIC_HOST1_8080}});
- And [SharingHub]({{TRAFFIC_HOST1_30080}}) 

before proceeding to the next step.
