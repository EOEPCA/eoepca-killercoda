we have now a [OGC Process API](https://ogcapi.ogc.org/processes/) compliant interface offered by zoo, which we can use to deploy and run applications within our platform.

Applications in Zoo are deployed according to the [OGC Best Practices for Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html). These specify applications packaged in a [Docker](https://www.docker.com/) container, with input, output and processing steps defined in a [CWL file](https://www.commonwl.org/).

You can see what a sample CWL application looks like from the deployment guide examples, via

```

less examples/convert-url-app.cwl

```{{exec}}

As you can see, this application is very basic. It takes as input an operation to be performed (defaults to "resize"), an image, and a resize percentage and it will output the resized image.

The application will run the "convert.sh" command-line script present in the "eoepca/convert" docker container with the inputs provided.

If you want to know more about EO Application Package applications, you can visit the [Earth Observation Application Package](https://github.com/eoap) tutorials web page.

When you finished inspecting the application, you can press `q`{{exec}} to exit and move to the next step.