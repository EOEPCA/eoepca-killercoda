ZOO-Project and Calrissian need shared ReadWriteMany storage. The tutorial supplies the `standard` storage class.

Create a test claim:

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

Wait for the claim to bind:

```
kubectl wait --for=jsonpath='{.status.phase}'=Bound pvc/test-rwx-pvc --timeout=60s
kubectl get pvc test-rwx-pvc
```{{exec}}

Delete the test claim:

```
kubectl delete pvc/test-rwx-pvc
```{{exec}}
