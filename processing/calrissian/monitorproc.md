Now the application is running. We can see, after few seconds, that a new namespace starting with `convert-url`{{}} is created,

```
kubectl get namespaces
```{{exec}}

and, after another few seconds, it will be populated with the pods of our kubernetes job

```
kubectl get -n `kubectl get namespaces | grep ^convert-url | cut -d' ' -f 1` pods
```{{exec}}

the status of the processing is can be monitored via the API, via

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/${JOB_ID}" | jq
```{{exec}}

at some point our job will be successful, and the status will show the "finished" state.

Let's wait for our job to complete via the following. Note that the first time a job is run, it will take some time, as all the containers needs to be downloaded by kubernetes

```
while [[ "$JOB_STATUS" != "finished" ]]; do
  JOB_STATUS=`curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/${JOB_ID}" | jq .status`
  echo status is $JOB_STATUS...
  echo pods are:
  kubectl get -n `kubectl get namespaces | grep ^convert-url | cut -d' ' -f 1` pods
  sleep 1
done
```{{exec}}

A link to the result will be then accessible from the status page, and also available directly into the object storage.

If the job completed successfully, the namespace will be also cleaned up, and you will not be able to find it anymore.

```
#Wait till the job completes
while [ `curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/${JOB_ID}" | jq .status` != "finished" ]; do sleep 5; done
#Check the namespace has been deleted (empty result)
kubectl get namespaces | grep ^convert-url
#Check the output is available in the object storage
mc ls -r minio-local/eoepca
```{{exec}}
