NOTE TODO: This needs to be removed, the buckets are not used... maybe they are used for DVC...

an S3 object storage is required for storing outputs of the processing we will use two S3 buckets:
 - `mlopbb-sharinghub`{{}} for storing the datasets of the SharingHub
 - `mlopbb-mlflow-sharinghub`{{}} for storing the experiments results of MLFlow

An external object storage can be used, but here for simplicity we will use the minio object storage installed as per the [EOEPCA pre-requisites tutorial](../pre-requisites).

To check it is properly installed, you can run

```
mc ls minio-local
```{{exec}}

and check that you have the buckets above created.

Note that the configuration of the S3 object storage to be configured in the data processing engine is included in the `~/.eoepca/state`{{}} file.

You can view this file via `cat ~/.eoepca/state`{{exec}}
