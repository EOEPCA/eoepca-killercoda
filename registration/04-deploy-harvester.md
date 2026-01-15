If you have enabled Landsat or Sentinel 2 harvesting, or if you wish to create your own harvester, you will need to deploy the harvester components.

## Flowable

First, deploy the Flowable workflow engine:

```
helm repo add flowable https://flowable.github.io/helm/
helm repo update flowable
helm upgrade -i registration-harvester-api-engine flowable/flowable \
  --version 7.0.0 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/generated-values.yaml
```{{exec}}

and its Ingress:

```
kubectl apply -f registration-harvester/generated-ingress.yaml
```{{exec}}


## eodata Volume

The harvesters harvest data into a location shared by all harvesters and from which it can be served to users. A PersistentVolume must be created for each harvester, each pointing to the same underlying storage. If either the Landsat or Sentinel harvesters are enabled you must create these now. Because we are using the hostpath provisioner we can do it like this:

```
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: eodata-landsat
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 100Gi
  persistentVolumeReclaimPolicy: Delete
  storageClassName: ${SHARED_STORAGECLASS}
  volumeMode: Filesystem
  hostPath:
    type: DirectoryOrCreate
    path: /tmp/hostpath-provisioner/resource-registration/eodata
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: eodata-sentinel
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 100Gi
  persistentVolumeReclaimPolicy: Delete
  storageClassName: ${SHARED_STORAGECLASS}
  volumeMode: Filesystem
  hostPath:
    type: DirectoryOrCreate
    path: /tmp/hostpath-provisioner/resource-registration/eodata
EOF
```{{exec}}

## Landsat and Sentinel Harvesters

To harvest Landsat data a special Landsat Harvester Worker needs to be running. It can be installed using Helm

```
helm upgrade -i registration-harvester-worker-landsat eoepca/registration-harvester \
  --version 2.0.0-rc3 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/harvester-values/values-landsat.yaml
```{{exec}}

Similarly for Sentinel

```
helm upgrade -i registration-harvester-worker-sentinel eoepca/registration-harvester \
  --version 2.0.0-rc3 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/harvester-values/values-sentinel.yaml
```{{exec}}


## Validation

Flowable and the Landsat and Sentinel Harvesters may take several minutes to start.

We can validate the deployment and check that startup has completed with the provided script `validation.sh`{{}}

```
bash validation.sh
```{{exec}}

Again, we can also check the status of the Kubernetes resources directly (there will be more of them now)

```
kubectl get all -n resource-registration
```{{exec}}

