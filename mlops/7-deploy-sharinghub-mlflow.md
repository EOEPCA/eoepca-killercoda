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

Before deploying MLflow, we need to disable its internal postgresql database. This is not something we want to do in prouction, as the PostgreSQL database is used for persistence, but we can do in our sandbox environment to reduce resource consumption and speed-up deployment time. To do so, we run

```
sed -i '/dependencies:/,$d' mlflow-sharinghub-0.2.0/deploy/helm/mlflow-sharinghub/Chart.yaml
```{{exec}}

and deploy MLflow via

```bash
helm upgrade -i mlflow-sharinghub mlflow-sharinghub-0.2.0/deploy/helm/mlflow-sharinghub/ --namespace sharinghub --values mlflow/generated-values.yaml --set postgresql.enabled=false
```{{exec}}

Let's wait for the container to start with

```
kubectl -n sharinghub wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

At this point, we have completed the deployment of our Sharinghub and MLFlow services on Kuberetes. We need to turn back on the Gitlab to use the entire system, but as we have limited resources in our environment, we first turn off the Kubernetes control panel. Note that this has no inpact on the running Sharinghub and MLFlow services, as they will continue to work as expected.

```bash
#Turn down kubernetes controlpanel (only because we are limited on resources in this sandbox)
service k3s stop
#Restart the gitlab
docker start gitlab
```{{exec}}

We need to wait back again for the gitlab to turn up. This can take again some minutes. To wait for gitlab initialization we can run

```
while [[ "`curl -s -o /dev/null -w "%{http_code}" "{{TRAFFIC_HOST1_8080}}"`" != "302" ]]; do sleep 10; done
```{{exec}}

Confirm that you can:
- [Visit GitLab]({{TRAFFIC_HOST1_8080}});
- And [SharingHub]({{TRAFFIC_HOST1_80}}) 
- And [MLFlow]({{TRAFFIC_HOST1_80}}/mlflow)

before proceeding to the next step.
