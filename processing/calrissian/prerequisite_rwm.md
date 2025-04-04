a Read-Write-Many Storage Class is a pre-requisite.

This is not normally provided by all the Kubernetes CSI storage drivers, nor by most Kubernetes cloud services. It can be anyway installed as per the [EOEPCA pre-requisites tutorial](../pre-requisites).

Here we have installed a `standard`{{}} StorageClass supporting Read-Write-Many. To check it is available and working properly, you can try to instantiate a Read-Write-Many persistent volume:

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-rwx-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
EOF
```{{exec}}

and check that this is created and in the status `Bound` via

```
kubectl get pvc
```{{exec}}

and then it can be deleted

```
kubectl delete pvc/test-rwx-pvc
```{{exec}}

We are now ready to start with our deployment
