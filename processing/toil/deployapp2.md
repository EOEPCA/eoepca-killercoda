We can now deploy the `convert-url`{{}} application. According to [OGC API - Processes](https://ogcapi.ogc.org/processes/), an application package is registered by posting its CWL definition to the processes endpoint.

New applications are added to a user namespace rather than the general `http://zoo.eoepca.local/ogc-api/processes/`{{}} endpoint. Authentication is disabled in this tutorial, so we will use the example namespace `test`{{}}.

Check the processes already available in that namespace:

```
curl --silent --show-error \
  http://zoo.eoepca.local/test/ogc-api/processes/ \
  | jq -r '.processes[].id'
```{{exec}}

Only the built-in `echo`{{}} process should be present.

Deploy the application by posting the CWL with its correct media type:

```
curl --silent --show-error \
  --request POST \
  --header "Content-Type: application/cwl+yaml" \
  --header "Accept: application/json" \
  --data-binary @/tmp/assets/convert-url-app.cwl \
  http://zoo.eoepca.local/test/ogc-api/processes/ \
  | jq
```{{exec}}

The first deployment can take around a minute while ZOO-Project generates the process wrapper.

If everything worked, `convert-url`{{}} is now included in the list of deployed applications:

```
curl --silent --show-error \
  http://zoo.eoepca.local/test/ogc-api/processes/ \
  | jq -r '.processes[].id'
```{{exec}}

No new application pod is created in Kubernetes at this point. The CWL is stored by ZOO-Project, and Toil submits application work to HTCondor only after an execution request is received.
