If you have enabled Landsat or Sentinel 2 harvesting, or if you wish to create your own harvester, you will need to deploy the harvester components.

## Operaton

First, deploy the Operaton BPM workflow engine:

```
helm repo add operaton https://dlr-terrabyte.github.io/operaton-helm/
helm repo update operaton
helm upgrade -i registration-harvester-bpm-engine operaton/operaton \
  --version 1.0.6 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/generated-values.yaml
```{{exec}}

and its Ingress:

```
kubectl apply -f registration-harvester/generated-ingress.yaml
```{{exec}}


## eodata Volume

Each harvester worker stores their harvested data into a kubernetes persistent volume. We establish a single shared `eodata` volume to collate the outputs of all workers - and also to provide a single asset location to facilitate delivery of data through external services.

The volume must be created as `ReadWriteMany` - and thus should use the `SHARED_STORAGECLASS` specified at the earlier configuration step.

```
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: eodata
  namespace: resource-registration
  labels:
    app.kubernetes.io/name: registration-harvester
    app.kubernetes.io/component: eodata-storage
  annotations:
    helm.sh/resource-policy: keep
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ${SHARED_STORAGECLASS}
  resources:
    requests:
      storage: 100Gi
EOF
```{{exec}}

To serve this over HTTP this tutorial uses nginx:

```bash
kubectl apply -f registration-harvester/generated-eodata-server.yaml
```{{exec}}

The data will become visible from outside the tutorial environment under [this URL]({{TRAFFIC_HOST1_84}}) and within it from `http://eodata.eoepca.local/`.

## Landsat, Sentinel and STAC Harvesters

To harvest Landsat data a special Landsat Harvester Worker needs to be running. It can be installed using Helm

```
helm upgrade -i registration-harvester-worker-landsat eoepca/registration-harvester \
  --version 2.0.0 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/harvester-values/values-landsat.yaml
```{{exec}}

Similarly for Sentinel

```
helm upgrade -i registration-harvester-worker-sentinel eoepca/registration-harvester \
  --version 2.0.0 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/harvester-values/values-sentinel.yaml
```{{exec}}

and for STAC

```
helm upgrade -i registration-harvester-worker-stac eoepca-dev/registration-harvester \
  --version 2.0.0 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/harvester-values/values-stac.yaml
```{{exec}}

## Validation

Operaton and the Landsat and Sentinel Harvesters may take several minutes to start.

We can validate the deployment and check that startup has completed with the provided script `validation.sh`{{}}

```
bash validation.sh
```{{exec}}

Again, we can also check the status of the Kubernetes resources directly (there will be more of them now)

```
kubectl get all -n resource-registration
```{{exec}}

