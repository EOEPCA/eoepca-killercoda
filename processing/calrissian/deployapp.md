The application is packaged as a container with its inputs, outputs and workflow described in CWL, following the [OGC Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html) best practice.

Inspect the example:

```
less examples/convert-url-app.cwl
```{{exec}}

The `convert-url` workflow calls `convert.sh` in the `eoepca/convert` container. Its inputs select the operation, source image URL and resize percentage. Its output is a directory containing the converted image and STAC metadata.

Press `q`{{exec}} to exit.
