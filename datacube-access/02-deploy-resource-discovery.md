
First, we need to deploy the Resource Discovery BB which will serve as our STAC catalog. For detailed information about Resource Discovery, see the [dedicated tutorial](https://killercoda.com/eoepca/scenario/resource-discovery).

### Configure Resource Discovery

```
bash configure-resource-discovery.sh
```{{exec}}

The shared domain, storage class and TLS settings were already configured in the earlier
prerequisites step. The only remaining question is whether to enable the IAM-protected,
writable catalogue endpoint - we don't need authenticated writes for this tutorial:
```
no
```{{exec}}

### Deploy with Helm

Add the helm repository and deploy:

```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
```{{exec}}

```
helm upgrade -i resource-discovery eoepca-dev/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.1.0-dev2 \
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
for i in {1..12}; do
  code=$(curl -s -o /tmp/resource-catalogue-stac.json -w "%{http_code}" "http://resource-catalogue.eoepca.local/stac" || true)
  echo "Attempt $i/12: HTTP $code"
  if [ "$code" = "200" ]; then
    echo "Resource Discovery is ready!"
    break
  fi
  kubectl get pods -n resource-discovery
  sleep 30
done
test "$code" = "200"
```{{exec}}

### Verify Deployment

```
curl -s "http://resource-catalogue.eoepca.local/stac" | jq '{title: .title, description: .description}'
```{{exec}}

## Visit the Resource Discovery UI
[Click this link to view the Resource Discovery UI]({{TRAFFIC_HOST1_81}})


The Resource Discovery BB is now running and ready for data ingestion.
