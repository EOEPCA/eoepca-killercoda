Our workflow has run successfully, so the final step is to verify that the output was correctly staged-out to our MinIO S3 bucket.

The `argo-cwl-runner-stage-in-out` template is configured to place results in the `results` bucket, inside a directory named after the unique job ID (`usid`). In our `test.py` script, we hardcoded this ID to `abc-1234`.

Let's use the `mc` client to list the contents of the results bucket.

```bash
mc ls local-minio/results
```{{exec}}

You should see our job ID, `abc-1234`. Now, let's look inside that directory. The output name `result_directory` comes from the `outputs` section of our CWL file.

```bash
mc ls local-minio/results/abc-1234/
```{{exec}}

This confirms that the entire process worked end-to-end. The runner submitted the workflow to Argo, Argo executed the CWL tool in a container, and the results were successfully transferred to our S3 storage.

You can even view the contents of the file:

```bash
mc cat local-minio/results/abc-1234/catalog.json | jq
```{{exec}}

Due to the resource constraints of this environment, we used a simple showcase application that downloads a static STAC catalog. In a real-world scenario, you would replace this with your actual logic.