an S3 object storage is required for storing outputs of the processing we will use a local `eoepca`{{}} S3 bucket.

An external object storage can be used, but here for simplicity we will use the minio object storage installed as per the [EOEPCA pre-requisites tutorial](../pre-requisites).

To check it is properly installed, you can run

```

mc ls minio-local

```{{exec}}

The `mc ls` command, part of the MinIO client, lists the content of and checks that you have an `eoepca`{{}} bucket created.

Note that the configuration of the S3 object storage to be configured in the data processing engine is included in the `~/.eoepca/state`{{}} file.

You can view this file via `cat ~/.eoepca/state`{{exec}}
