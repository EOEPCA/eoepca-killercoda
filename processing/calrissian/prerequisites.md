As ususal in this tutorial, we will use the EOEPCA deployment-guide scripts to help us configuring and deploying our application. Let's clone it in our environment

```
git clone https://github.com/EOEPCA/deployment-guide
```{{exec}}

the OGC API Process interface deployment scripts are available in the `processing/oapip` directory, let's open it

```
cd ~/deployment-guide/scripts/processing/oapip
git checkout killercoda-demo
```{{exec}}

As specified in the deployment guide, the OGC API Process interface, Calrissian Kubernetes engine, requires the following pre-requisites:

### a kubernetes cluster
with some minimal constraints, such as the availability of an ingress controller to expose the EOEPCA building block interfaces, DNS entries to map the EOEPCA interface endpoints and certificates to provide SSL support.

Here for simplicity, we will use the basic nginx ingress controller, static DNS entries and no SSL support, as described in the [EOEPCA pre-requisites tutorial](../pre-requisites).

To check the Kubernetes cluster is properly installed, run `kubectl get -n ingress-nginx pods`{{exec}}, which should return an `ingress-nginx-controller`{{}} pod, and try to access the storage and data processing endpoints with `curl -s -S http://zoo.eoepca.local` which should return a `404 Not Found`{{}} nginx error page, as we did not install our services yet.

### an S3 object storage
for storing outputs of the processing we will use a local `eoepca`{{}} S3 bucket. An external object storage can be used, but here for simplicity we will use the minio object storage installed as per the [EOEPCA pre-requisites tutorial](../pre-requisites).

To check it is properly installed, you can run `mc ls minio-local`{{exec}} and check that you have an `eoepca`{{}} bucket bucket created.

Note that the configuration of the S3 object storage to be configured in the data processing engine is included in the `~/.eoepca/state`{{}} file. You can view this file via `less ~/.eoepca/state`{{exec}} (press `q`{{exec}} to exit after)

### a Read-Write-Many Storage Class
as this is a pre-requisite for Calrissian. This is not normally provided by all the Kubernetes CSI storage drivers, nor by most Kubernetes cloud services. It can be anyway installed as per the [EOEPCA pre-requisites tutorial](../pre-requisites).

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

and check that this is created and bounded via

```
kubectl get pvc
```{{exec}}

and then it can be deleted

```
kubectl delete test-rwx-pvc
```{{exec}}


