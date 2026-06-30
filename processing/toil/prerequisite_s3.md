S3-compatible object storage is required for storing processing outputs. In this tutorial, we use a local `eoepca`{{}} bucket.

An external object store can be used, but for simplicity we use the MinIO service installed as part of the Localcoda prerequisites.

Check that it is available:

```
mc ls minio-local
```{{exec}}

You should see the `eoepca/`{{}} bucket.

The object-storage endpoint and credentials used by the processing engine are stored in `~/.eoepca/state`{{}}. View the state with:

```
cat ~/.eoepca/state
```{{exec}}

The Deployment Guide configuration script will read these values and ask whether they should be retained.
