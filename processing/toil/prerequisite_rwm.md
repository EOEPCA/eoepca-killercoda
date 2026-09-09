A ReadWriteMany Storage Class is a prerequisite for ZOO-Project.

This is not provided by every Kubernetes CSI storage driver or cloud service. It can be installed as described in the [EOEPCA prerequisites tutorial](https://killercoda.com/eoepca/scenario/prerequisites).

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

Wait for the claim to bind, and check that it reports the `RWX` access mode:

```
kubectl wait --for=jsonpath='{.status.phase}'=Bound pvc/test-rwx-pvc --timeout=60s
kubectl get pvc test-rwx-pvc
```{{exec}}

The claim is only a prerequisite test, so delete it before continuing:

```
kubectl delete pvc test-rwx-pvc
```{{exec}}
