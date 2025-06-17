
## Deploying SharingHub & MLflow

**Temporarily turn off GitLab docker container**:

```bash
docker stop $(docker ps -qf "name=gitlab")
```{{exec}}

**Update Helm Repositories**:

```bash
curl -L https://github.com/csgroup-oss/sharinghub/archive/refs/tags/0.4.0.tar.gz | tar xvz 
curl -L https://github.com/csgroup-oss/mlflow-sharinghub/archive/refs/tags/0.2.0.tar.gz | tar xvz
```{{exec}}

**Deploy SharingHub**:

```bash
helm upgrade -i sharinghub sharinghub-0.4.0/deploy/helm/sharinghub/ -n sharinghub \
--create-namespace --values sharinghub/generated-values.yaml
```{{exec}}

**Cleanup** (as we're on a very resource-tight environment):

```bash
rm -rf sharinghub-0.4.0
apt-get clean
crictl rmi --prune
```{{exec}}

**Deploy MLflow**:


```bash
helm dependency build mlflow-sharinghub-0.2.0/deploy/helm/mlflow-sharinghub/
helm upgrade -i mlflow-sharinghub mlflow-sharinghub-0.2.0/deploy/helm/mlflow-sharinghub/ --namespace sharinghub --values mlflow/generated-values.yaml
```{{exec}}

```bash
rm -rf mlflow-sharinghub-0.2.0
```

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