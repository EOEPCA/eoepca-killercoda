We have now our `convert-url`{{}} application deployed in our platform, we can submit a processing request.

Once the processing request is submitted, Zoo will invoke Calrissian, which will then create a new Kubernetes namespace in the same Kubernetes cluster where Zoo and the [OGC Process API](https://ogcapi.ogc.org/processes/) interface is installed and start there the application jobs. The jobs will gather the input, execute the processing and in the push the output inside the platform object storage. From the [OGC Process API](https://ogcapi.ogc.org/processes/) interface we will be able to monitor the status of the job and, at the end of its successful completition, retreive its output.

So, let's start to submit a processing request to the convert-url application. We can check the application inputs from the API via

```
curl -s -S http://zoo.eoepca.local/test/ogc-api/processes/convert-url | jq
```{{exec}}

As you can see, and as you may recall from the CWL submitted in the previous step, this application requires three inputs, "fn", "url" and "size". As example, we can just use their default value in the job submission, via

```
JOB_ID=$(
  curl --silent --show-error \
    -X POST http://zoo.eoepca.local/test/ogc-api/processes/convert-url/execution \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -H "Prefer: respond-async" \
    -d @- <<EOF | jq -r '.jobID'
  {
    "inputs": {
      "fn": "resize",
      "url":  "https://eoepca.org/media_portal/images/logo6_med.original.png",
      "size": "50%"
    }
  }
EOF
)
```{{exec}}

the execution returns us a job id, which we are saving in the `$JOB_ID`{{}} variable for later use, and looks like this:

```
echo "$JOB_ID"
```{{exec}}

Now the application is running. We can see, after few seconds, that a new namespace starting with `convert-url`{{}} is created,

```
kubectl get namespaces
```{{exec}}

and, after another few seconds, it will be populated with the pods of our kubernetes job

```
kubectl get -n `kubectl get namespaces | grep ^convert-url | cut -d' ' -f 1` pods
```{{exec}}

the status of the processing is also available via the API, via

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/${JOB_ID}" | jq
```{{exec}}

at some point it will be successful, and the status will show the "finished" state. A link to the result will be then accessible from the status page, and also available directly into the object storage.

If the job completed successfully, the namespace will be also cleaned up, and you will not be able to find it anymore.

```
#Wait till the job completes
while [ `curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/${JOB_ID}" | jq .status` != "finished" ]; do sleep 5; done
#Check the namespace has been deleted (empty result)
kubectl get namespaces | grep ^convert-url
#Check the output is available in the object storage
mc ls -r minio-local/eoepca
```{{exec}}