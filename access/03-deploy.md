```
helm upgrade -i pgo oci://registry.developers.crunchydata.com/crunchydata/pgo \
  --version 5.6.0 \
  --namespace data-access \
  --create-namespace \
  --values postgres/generated-values.yaml
```{{exec}}

```
helm repo add eoapi https://devseed.com/eoapi-k8s/
helm repo update eoapi
helm upgrade -i eoapi eoapi/eoapi \
  --version 0.6.0 \
  --namespace data-access \
  --values eoapi/generated-values.yaml
```{{exec}}

```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
helm upgrade -i stac-manager eoepca-dev/stac-manager \
  --version 0.0.3 \
  --namespace data-access \
  --values stac-manager/generated-values.yaml
```{{exec}}

```
helm upgrade -i eoapi-maps-plugin eoepca-dev/eoapi-maps-plugin \
  --version 0.0.21 \
  --namespace data-access \
  --values eoapi-maps-plugin/generated-values.yaml
```{{exec}}


```
kubectl --namespace data-access wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}






<!--
We can now deploy the Resouce Discovery building block. 

First must add the software helm repository.

```
helm repo add eoepca https://eoepca.github.io/helm-charts
helm repo update
```{{exec}}

Then we deploy the software via helm, using the configuration values generated in the previous step.

```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
helm upgrade -i resource-discovery eoepca-dev/rm-resource-catalogue \
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

We can also check manually:
- the endpoints provided by the Resource Discovery service
  ```
  curl -s "http://resource-catalogue.eoepca.local" | jq
  ```{{exec}}
- the capabilities containing service metadata in XML format
  ```
  curl -s "http://resource-catalogue.eoepca.local/csw?service=CSW&version=2.0.2&request=GetCapabilities" | xmllint --format -
  ```{{exec}}
- STAC API
  ```
  curl -s "http://resource-catalogue.eoepca.local/stac" | jq
  ```{{exec}}
-->

