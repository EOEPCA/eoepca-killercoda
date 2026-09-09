Calrissian creates the execution namespace after accepting the job. While it is running, inspect its pods:

```
kubectl get pods -n "$JOB_NAMESPACE"
```{{exec}}

If the namespace does not exist yet, wait a few seconds and run the command again.

The `job-...` pod is Calrissian running the CWL workflow; the pods beside it are the workflow steps, such as the `stage-out-0-pod-...` that uploads the output to object storage. The namespace is removed when execution finishes, so use the API to check progress:

```
curl -sS "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq
```{{exec}}

Repeat the request after a few seconds until `status` is `successful`. The first execution takes longer while Kubernetes downloads the images. If the status is `failed`, inspect the message and the logs linked below before continuing.

A finished job links to the log of each workflow step. Read the stage-out log:

```
curl -sS "http://zoo.eoepca.local/test/temp/convert-url-$JOB_ID/stage_out_0.log" | tail -n 10
```{{exec}}

It shows the pod that ran the step and the objects it uploaded to `s3://eoepca/processing-results/`. The `convert.log` link beside it holds the application step's own output, which is empty for this example.
