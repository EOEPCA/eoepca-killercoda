A ReadWriteMany Storage Class is a prerequisite for ZOO-Project.

This is not provided by every Kubernetes CSI storage driver or cloud service. It can be installed as described in the [EOEPCA prerequisites tutorial](../../prerequisites).

Here we have installed a `standard`{{}} StorageClass that supports ReadWriteMany. Check that it works by creating a temporary persistent volume claim:

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

Check that the claim has reached the `Bound` status and reports the `RWX` access mode:

```
kubectl get pvc test-rwx-pvc
```{{exec}}

The claim is only a prerequisite test, so delete it before continuing:

```
kubectl delete pvc test-rwx-pvc
```{{exec}}
