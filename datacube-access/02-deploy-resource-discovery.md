
First, we need to deploy the Resource Discovery BB which will serve as our STAC catalog. For detailed information about Resource Discovery, see the [dedicated tutorial](https://killercoda.com/eoepca/scenario/resource-discovery).

### Configure Resource Discovery

```
bash configure-resource-discovery.sh
```{{exec}}

Accept the defaults:
```
no
no
```{{exec}}

### Deploy with Helm

Add the helm repository and deploy:

```
helm repo add eoepca https://eoepca.github.io/helm-charts-dev
helm repo update
```{{exec}}

```
helm upgrade -i resource-discovery eoepca/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.0.0-rc2 \
  --namespace resource-discovery \
  --create-namespace \
  --set db.volume_access_modes=ReadWriteOnce
```{{exec}}

Create the ingress:

```
kubectl apply -f generated-ingress.yaml
```{{exec}}

### Wait for Deployment

Wait for the Resource Discovery service to be ready:

```
while [[ `curl -s -o /dev/null -w "%{http_code}" "http://resource-catalogue.eoepca.local/stac"` != 200 ]]; do sleep 1; done
echo "Resource Discovery is ready!"
```{{exec}}

### Verify Deployment

```
curl -s "http://resource-catalogue.eoepca.local/stac" | jq '{title: .title, description: .description}'
```{{exec}}

## Visit the Resource Discovery UI
[Click this link to view the Resource Discovery UI]({{TRAFFIC_HOST1_81}})


The Resource Discovery BB is now running and ready for data ingestion.