we have now a [OGC Process API](https://ogcapi.ogc.org/processes/) compliant interface offered by zoo, which we can use to deploy and run applications within our platform.

Applications in Zoo are deployed according to the [OGC Best Practices for Earth Observation Application Pakcage](https://docs.ogc.org/bp/20-089r1.html). These specify applications packaged in a [Docker](https://www.docker.com/) container, with input, output and processing steps defined in a [CWL file](https://www.commonwl.org/).

You can see what a sample CWL application looks like from the deployment guide examples, via

```
less examples/convert-url-app.cwl
```{{exec}}

As you can see, this application is very basic. It takes as input an operation to be performed (defaults to "resize"), an image, and a resize percentage and it will output the resized image. The application will run the "convert.sh" command-line script present in the "eoepca/convert" docker container with the inputs provided.

If you want to know more about EO Application Package applications, you can visit the [Earth Observation Application Package](https://github.com/eoap) tutorials web page.

So, let's try to deploy this application. To do so, we need, according to the [OGC Process API](https://ogcapi.ogc.org/processes/), to POST the CWL file. We cannot post this to the general Zoo endpoint, `http://zoo.eoepca.local/ogc-api/processes/`{{}}, as for security reasons new applications needs to be added to a user namespace. As we do not have authentication enabled, we can just add any user namespace to the endpoint, thus have, for example `http://zoo.eoepca.local/test/ogc-api/processes/`{{}} for a `test`{{}} namespace.

Now that we have the endpoint, we can post the convert application via:

```
curl -s -S -X POST -H "Content-Type: application/cwl+yaml" -H "Accept: application/json" -d "`cat examples/convert-url-app.cwl`" http://zoo.eoepca.local/test/ogc-api/processes/  | jq
```

If all went well, the convert-url application is now deployed, and you can see it in the list of deployed applications:

```
curl -s -S http://zoo.eoepca.local/test/ogc-api/processes/ | jq
```{{exec}}

Nothing changed now in our Kubernetes cluster. The CWL is stored within the Zoo software and the actual application docker containers and pods will be deployed on-demand only after we submit a processing execution