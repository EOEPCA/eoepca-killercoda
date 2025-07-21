Now the application is running. We can see, after a few seconds, that a new Argo Workflow has been created in the `argo` namespace.

```
kubectl get workflows -n argo
```{{exec}}

You can inspect the details of the workflow, including its status and the pods it has created:

```
kubectl describe workflow -n argo $(kubectl get workflows -n argo -l zoo-job-id=$JOB_ID -o name)
```{{exec}}

The status of the processing can also be monitored via the API:

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq
```{{exec}}

At some point our job will be successful, and the status will show the "succeeded" state.

Let's wait for our job to complete. Note that the first time a job is run, it will take some time, as all the containers need to be downloaded by Kubernetes.

```
JOB_STATUS=`curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq -r .status`
while [[ "$JOB_STATUS" == "accepted" || "$JOB_STATUS" == "running" ]]; do
  JOB_STATUS=`curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq -r .status`
  echo status is $JOB_STATUS...
  echo pods are:
  kubectl get -n `kubectl get namespaces | grep ^convert-url | cut -d' ' -f 1` pods
  sleep 5
done
```{{exec}}

We can now access the result page, which should be populated with the final processing status and the processing logs.

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq
```{{exec}}

If the job completed with the `successful` state, a link to the result will be then accessible from the status page as a STAC Item.

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID/results" | jq
```{{exec}}

The result STAC Item asset, our resized image, is also available directly from the object storage.

```

mc ls -r minio-local/eoepca

```{{exec}}

