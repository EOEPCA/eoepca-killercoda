We can now deploy the Resouce Discovery building block. 

First must add the software helm repository.

```
helm repo add eoepca https://eoepca.github.io/helm-charts-dev
helm repo update
```{{exec}}

Then we deploy the software via helm, using the configuration values generated in the previous step.

```
helm upgrade -i resource-discovery eoepca/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.0.0-rc1 \
  --namespace resource-discovery \
  --create-namespace
```{{exec}} 


Now we wait for the Resource Discovery pods to start. This may take some time, expecially in this demo environment. To automatically wait for all service to be ready you can run:

```
kubectl --namespace resource-discovery wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

Finally, we must create ingress for our newly created Resource Discovery service to make it available. We use the configuration file generated automatically in the previous step.

```
kubectl apply -f generated-ingress.yaml
```{{exec}}

Once deployed, the Resouce Discovery STAC API should be accessible at `http://resouce-catalogue.eoepca.local`

We can validate it with the provided script `validation.sh`

```
bash validation.sh
```{{exec}}

We can also check manually the provided STAC API via:

```
curl -s "http://resource-catalogue.eoepca.local/stac" | jq
```{{exec}}
