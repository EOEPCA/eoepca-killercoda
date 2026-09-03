The harvester consists of the Operaton BPM workflow engine, a shared `eodata` volume, and one worker per data source. We deploy Operaton, the volume and the STAC worker here - the Landsat and Sentinel workers are optional and deployed as part of their own dedicated steps later, since they need provider credentials most attendees won't have to hand.

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

## STAC Harvester

The generic STAC-catalog harvester, used in the next step to harvest from a real public STAC API, can be installed using Helm:

```
helm upgrade -i registration-harvester-worker-stac eoepca-dev/registration-harvester \
  --version 2.0.0 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/harvester-values/values-stac.yaml
```{{exec}}

## Validation

Operaton and the harvester worker may take several minutes to start.

We can validate the deployment and check that startup has completed with the provided script `validation.sh`{{}}

```
bash validation.sh
```{{exec}}

> `validation.sh` always checks for the Landsat and Sentinel workers and a total of 6 pods - since this tutorial only deploys the STAC worker by default, expect it to report 3 failures (pod count, Landsat service, Sentinel service) here. Everything else passing confirms the deployment is healthy.

Again, we can also check the status of the Kubernetes resources directly

```
kubectl get all -n resource-registration
```{{exec}}
