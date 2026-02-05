
Now let's deploy the Datacube Access building block, which filters the STAC catalog to expose only datacube-ready collections.

### Check Prerequisites

```
bash check-prerequisites.sh
```{{exec}}

### Configure Datacube Access

```
bash configure-datacube-access.sh
```{{exec}}

Enter the domain:
```
eoepca.local
```{{exec}}

Cluster issuer (use default):
```
letsencrypt-http01-apisix
```{{exec}}

Storage class:
```
local-path
```{{exec}}

STAC catalog endpoint (pointing to Resource Discovery):
```
http://resource-catalogue.eoepca.local/stac
```{{exec}}

### Deploy Datacube Access

```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
helm upgrade -i datacube-access eoepca-dev/datacube-access \
  --values generated-values.yaml \
  --version 2.0.0-rc2 \
  --namespace datacube-access \
  --create-namespace
```{{exec}}


### Wait for Deployment

```
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=datacube-access -n datacube-access --timeout=180s
```{{exec}}

Check deployment status:

```
kubectl get all -n datacube-access
```{{exec}}

### Validate Deployment

```
bash validation.sh
```{{exec}}

Test the landing page:

```
curl -s "http://datacube-access.eoepca.local/" | jq '{title, description}'
```{{exec}}

## Visit the Datacube Access UI
[Click this link to view the Datacube Access UI]({{TRAFFIC_HOST1_82}})

The Datacube Access building block is now deployed and connected to the Resource Discovery catalog.