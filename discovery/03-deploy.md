We can now deploy the Resource Discovery building block. 

First we must add the software helm repository.

```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
```{{exec}}

Then we deploy the software via helm, using the configuration values generated in the previous step.

```
helm upgrade -i resource-discovery eoepca-dev/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.0.0-rc4 \
  --namespace resource-discovery \
  --create-namespace
```{{exec}}

And we create the ingress for our newly created Resource Discovery service to make it available, using the configuration file generated automatically in the previous step.

```
kubectl apply -f generated-ingress.yaml
```{{exec}}

Now we wait for the Resource Discovery pods to start. This may take some time, especially in this demo environment. To automatically wait till all service to are ready you and the catalogue responds correctly you can run:

```
while [[ `curl -s -o /dev/null -w "%{http_code}" "http://resource-catalogue.eoepca.local/stac"` != 200 ]]; do sleep 1; done
```{{exec}}

Once deployed, the Resource Discovery STAC API should be accessible at `http://resource-catalogue.eoepca.local`{{}}

We can validate it with the provided script `validation.sh`{{}}

```
bash validation.sh
```{{exec}}

We can also check manually the provided STAC API via:

```
curl -s "http://resource-catalogue.eoepca.local/stac" | jq
```{{exec}}

Or have a look at the catalogue web interface from [this link]({{TRAFFIC_HOST1_81}}) (come back here afterwards, the tutorial is not over).
