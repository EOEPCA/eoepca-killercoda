All of EOEPCA Building Blocks, with very few exceptions will require a [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/) setup in the Kubernetes Cluster for persistence of data.

A [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/) is a way for administrators to describe different *classes* of storage. Different classes might map to quality-of-service levels, or to backup policies, or to arbitrary policies determined by the cluster administrators. Kubernetes itself is unopinionated about what classes represent, but EOEPCA Building Blocks may require or recommend specific classes of storage satisyiing specific policie.

In particular, it is recommended in production to assign the EOEPCA persistent Storage Class to a backup-ed storage, as this storage class will contain information such as data metadata, user data, the status of the platform, logs, etc...

In addition, some EOEPCA Building Blocks, particularly those involved in processing (e.g. the CWL Processing Engine), require a storage class supporting the [ReadWriteMany](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) access mode. This allows to create volumens to which multiple pods can read and write concurrently.

To see the storage classes deployed in our sandbox environment we can run

```
kubectl get storageclass
```{{exec}}

As you can see, by default the `local-path`{{}} storage class is available. This is a local provisioner which supports only [ReadWriteOnly](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) access mode.


To have a [ReadWriteMany](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) storage class, there are several possible solutions, like [GlusterFS](https://www.gluster.org/), [Longhorn](https://longhorn.io/), [OpenEBS](https://openebs.io/) or a simple [NFS Provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner).

In this tutorial, anyway, we will use a quick-and-dirty solution which is using a Hostpath provisioner.

Note that THIS WILL NOT WORK if your cluster has more than one node, so for basically any production cluster and most development clusters, as the storage provisioned via the Hostpath provisioner will not be actually accessible from multiple nodes. If you are in a multi-node environment, please deploy one of the storage classes listed in the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/prerequisites/storage/#setting-up-storage-classes) or another storage class supporting ReadWriteMany.

To compigure the HostPath provisioner and its assosicated `standard` storage class we cn run:
```
kubectl apply -f https://raw.githubusercontent.com/EOEPCA/deployment-guide/refs/heads/main/docs/prerequisites/hostpath-provisioner.yaml
```{{exec}}

We can check if the provisioner has been deployed:
```
kubectl get -n kube-system sc/standard deploy/hostpath-storage-provisioner
```{{exec}}

Now, we can try to create a persistent volume claim (PVC) with ReadWriteMany access:
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

Check that the PVC is created and has the status `Bound`:
```
kubectl get pvc
```{{exec}}

Finally, the test PVC can be deleted:
```
kubectl delete pvc/test-rwx-pvc
```{{exec}}
