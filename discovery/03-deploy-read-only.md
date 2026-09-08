The Resource Discovery Building Block deploys two separate services for read access and for write access. We deploy the read-only service first.

We must add the software helm repository.

```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
```{{exec}}

Then we deploy the software via helm, using the configuration values generated in the previous step.

```
helm upgrade -i resource-catalogue eoepca-dev/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.1.0-dev2 \
  --namespace resource-discovery \
  --create-namespace
```{{exec}}

And we create the ingress for our newly created Resource Discovery service to make it available, using the configuration file generated automatically in the previous step.

```
kubectl apply -f generated-ingress.yaml
```{{exec}}


Now we wait for the Resource Discovery pods to start. This may take some time, especially in this demo environment. The catalogue restarts a couple of times while its database initialises.

```
while ! kubectl wait --for=condition=Ready --all=true -n resource-discovery pod --timeout=1m &>/dev/null; do
  sleep 10
  echo "Waiting for Resource Discovery readiness"
done

echo -e "\nResource Discovery is READY"
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
