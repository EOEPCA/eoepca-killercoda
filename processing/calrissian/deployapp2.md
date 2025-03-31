We can now try to deploy the `convert-url`{{}} application. To do so, we need, according to the [OGC Process API](https://ogcapi.ogc.org/processes/), to POST the CWL file.

We cannot post this to the general Zoo endpoint, `http://zoo.eoepca.local/ogc-api/processes/`{{}}, as for security reasons new applications needs to be added to a user namespace. As we do not have authentication enabled, we can just add any user namespace to the endpoint, thus have, for example `http://zoo.eoepca.local/test/ogc-api/processes/`{{}} for a `test`{{}} namespace.

If we have a look at the `test`{{}} user namespace, as in the command below, we can see that only the general sample `echo`{{}} process is available

```
curl -s -S http://zoo.eoepca.local/test/ogc-api/processes/  | jq -r .processes[].id
```{{exec}}

To deploy the application, we can do a POST to the the processes endpoint, including the CWL representing the [OGC Application Pakcage](https://docs.ogc.org/bp/20-089r1.html):

```
curl -s -S -X POST -H "Content-Type: application/cwl+yaml" -H "Accept: application/json" -d "`cat examples/convert-url-app.cwl`" http://zoo.eoepca.local/test/ogc-api/processes/  | jq
```{{exec}}

If all went well, the `convert-url`{{}} application is now deployed, and you can see it in the list of deployed applications:

```
curl -s -S http://zoo.eoepca.local/test/ogc-api/processes/ | jq -r .processes[].id
```{{exec}}

Nothing changed now in our Kubernetes cluster. The CWL is stored within the Zoo software and the actual application docker containers and pods will be deployed on-demand only after we submit a processing execution
