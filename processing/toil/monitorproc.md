Now the application is running. We can see, after a few seconds, that a new Toil WES request has been performed and is in processing:

```
tail -n 10 ~ubuntu/celery.log
```{{exec}}

and after another few seconds, Toil will start jobs in our HPC system (as ubuntu user)

```
condor_q -all
```{{exec}}

the status of the processing is can be monitored by the users via the API, via

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq
```{{exec}}

at some point our job will be successful, and the status will show the "finished" state.

Let's wait for our job to complete via the following. Note that the first time a job is run, it will take some time, as all the containers needs to be downloaded by kubernetes

```
JOB_STATUS=`curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq -r .status`
while [[ "$JOB_STATUS" == "accepted" || "$JOB_STATUS" == "running" ]]; do
  JOB_STATUS=`curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq -r .status`
  echo status is $JOB_STATUS...
  echo toil WES status is:
  tail -n 10 ~ubuntu/celery.log
  echo HTCondor queue status is:
  condor_q -all
  sleep 5
done
```{{exec}}

We can now access the result page, which should be populated with the final processing status and the processing logs

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq
```{{exec}}

If the job completed with the `successful` state, a link to the result will be then accessible from the status page as a STAC Item

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID/results" | jq
```{{exec}}

The result STAC Item asset, our resized image, is also available directly from the object storage

```
mc ls -r minio-local/eoepca
```{{exec}}

