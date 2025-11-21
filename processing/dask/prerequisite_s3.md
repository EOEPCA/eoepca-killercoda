
An S3 object storage is required for storing processing outputs and potentially for accessing input data. We'll use a local `eoepca` S3 bucket.

An external object storage can be used, but here for simplicity we'll use the minio object storage installed as per the [EOEPCA pre-requisites tutorial](../pre-requisites).

To check it's properly installed, run:

```bash
mc ls minio-local
```

The `mc ls` command, part of the MinIO client, lists the content and checks that you have an `eoepca` bucket created.

Let's also create a specific bucket for OpenEO data:

```bash
mc mb minio-local/openeo-data
mc mb minio-local/openeo-results
```

Set bucket policies for access:

```bash
mc anonymous set download minio-local/openeo-data
mc anonymous set download minio-local/openeo-results
```

Note that the configuration of the S3 object storage to be configured in the OpenEO backend is included in the `~/.eoepca/state` file.

You can view this file via:

```bash
cat ~/.eoepca/state
```

We'll also need to ensure our OpenEO backend can access this storage, which we'll configure in the next steps.