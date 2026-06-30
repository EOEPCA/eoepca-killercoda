We now have an [OGC API - Processes](https://ogcapi.ogc.org/processes/) compliant interface provided by ZOO-Project, which we can use to deploy and run applications on our platform.

Applications are deployed according to the [OGC Best Practice for Earth Observation Application Packages](https://docs.ogc.org/bp/20-089r1.html). These describe applications packaged in a [Docker](https://www.docker.com/) container, with their inputs, outputs, and processing steps defined in a [CWL file](https://www.commonwl.org/).

Inspect the sample CWL application included in the Deployment Guide:

```
less /tmp/assets/convert-url-app.cwl
```{{exec}}

This application is intentionally basic. It accepts an operation, an image URL, and a resize percentage, and outputs the resized image.

The `DockerRequirement` identifies the `eoepca/convert` container, while `baseCommand: convert.sh` identifies the command that Toil will execute through HTCondor.

For more information about EO Application Packages, visit the [Earth Observation Application Package tutorials](https://github.com/eoap).

Press `q`{{exec}} when you have finished inspecting the application.
