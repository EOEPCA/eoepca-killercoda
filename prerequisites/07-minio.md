As said before, EOEPCA requires an S3 Compatible Object storage. If you do not have this from the cloud provider, EOEPCA recomments to deploy it internally in the cluster and uses[ MinIO](https://min.io/) for this.

MinIO is a high-performance object storage system that’s compatible with the Amazon S3 API. In EOEPCA, MinIO can serve as the object storage backend for various services. There is also a possibility to configure an alternative S3-compatible object storage solution instead of MinIO e.g. use an external S3 storage provided by the cloud platform.

Note that in this step we will be deploying MinIO into our Kubernetes cluster following the instructions from the EOEPCA Deployment Guide. In other tutorial, a local MinIO server, external to the cluster, will be preinstalled as a prerequisite and used.

As usual, we will use scripts provided with the EOEPCA Deployment Guide:
```
cd ~/deployment-guide/scripts/minio
```{{exec}}

First, we check the prerequisites. At this point all of them should be met:
```
bash check-prerequisites.sh
```{{exec}}

Now we configure MinIO,
```
bash configure-minio.sh
```{{exec}}

we answer `no`{{}} to all questions since these values are already set correctly
```
no
no
no
```{{exec}}

We add the repository:
```
helm repo add minio https://charts.min.io/
helm repo update minio
```{{exec}}

And deploy MinIO into our Kubernetes cluster:
```
helm upgrade -i minio minio/minio \
  --version 5.4.0 \
  --values generated-values.yaml \
  --namespace minio \
  --create-namespace
```{{exec}}

We wait until the all pods in the `minio`{{}} namespace are ready:
```
kubectl --namespace minio wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

---

We must now create an Access Key for the user. Since we are working in a command line environment and cannot access MinIO Console with the browser, we will create the Access Key manually with the `mc`{{}} client that has been preinstalled.

First, we set the values of Access Key and Secret Key using the provided script:
```
bash apply-secrets.sh
eoepca
eoepcatest
```{{exec}}

Now we create our access key in MinIO. To do so we need first to install the MinIO client:

```
wget https://dl.min.io/client/mc/release/linux-amd64/mc -O  /usr/local/bin/mc && chmod +x /usr/local/bin/mc
```{{exec}}

The variables `MINIO_USER`{{}} and `MINIO_PASSWORD`{{}} have been set by the script `configure-minio.sh`{{}} and the variables `S3_ACCESS_KEY`{{}}, `S3_SECRET_KEY`{{}} have been set by the script `apply-secrets.sh`{{}} in the file `~/.eoepca/state`{{}}.

Set an alias in `mc`{{}} for our MinIO endpoint:
```
source ~/.eoepca/state
mc alias set minio-local http://minio.eoepca.local/ ${MINIO_USER} ${MINIO_PASSWORD}
```{{exec}}

Create Access Key:
```
mc admin accesskey create minio-local/ user --access-key ${S3_ACCESS_KEY} --secret-key ${S3_SECRET_KEY}
```{{exec}}

We can now validate our deployment with the provided script `validation.sh`{{}}. This requires `s3cmd`{{}} which we need to install before:
```
apt update && apt install -y s3cmd
bash validation.sh
y
```{{exec}}

Let's also do some manual checks using the `mc`{{}} client.
1. List the existing buckets in MinIO:
```
mc ls minio-local
```{{exec}}
1. Create a test bucket in MinIO:
```
mc mb minio-local/test-bucket
```{{exec}}
1. Create a local file and copy it to the test bucket:
```
echo "test" > test-file
mc cp test-file minio-local/test-bucket
```{{exec}}
1. List the content of the test bucket:
```
mc ls minio-local/test-bucket
```{{exec}}
1. Output the content of the test file in the bucket:
```
mc cat minio-local/test-bucket/test-file
```{{exec}}
1. Remove the test file, test bucket and check that they are gone:
```
mc rm minio-local/test-bucket/test-file
```{{exec}}
```
mc rb minio-local/test-bucket
```{{exec}}
```
mc ls minio-local
```{{exec}}
