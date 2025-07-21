We have now our `convert-url`{{}} application deployed in our platform, we can submit a processing request.

Once the processing request is submitted, Zoo will invoke the Argo engine, which will then create a new Argo Workflow in the configured `argo` namespace. This workflow will orchestrate the execution of the application.

The jobs within the workflow will gather the input, execute the processing and push the output inside the platform object storage.

From the [OGC Process API](https://ogcapi.ogc.org/processes/) interface we will be able to monitor the status of the job and, at the end of its successful completition, retrieve its output.

So, let's start to submit a processing request to the convert-url application.

We can check the inputs we need for submittign a processing request for this application from the API via

```

curl -s -S http://zoo.eoepca.local/test/ogc-api/processes/convert-url | jq .inputs

```{{exec}}

As you can see, and as you may recall from the CWL submitted in the previous step, this application requires three inputs: "fn", "url" and "size".

As example, we can just use their default values in the job submission, via

```

JOB\_ID=$(
  curl --silent --show-error  
    -X POST http://zoo.eoepca.local/test/ogc-api/processes/convert-url/execution  
    -H "Content-Type: application/json"  
    -H "Accept: application/json"  
    -H "Prefer: respond-async"  
    -d @- \<\<EOF | jq -r '.jobID'
  {
    "inputs": {
      "fn": "resize",
      "url":  "https://eoepca.org/media\_portal/images/logo6\_med.original.png",
      "size": "50%"
    }
  }
EOF
)
echo "$JOB\_ID"

```{{exec}}

the execution returned us a job id, which we are saving in the `$JOB_ID`{{}} variable for later use