Calrissian creates the execution namespace after accepting the job. While it is running, inspect its pods:

```
kubectl get pods -n "$JOB_NAMESPACE"
```{{exec}}

The namespace is removed when execution finishes. If there are no pods yet, or they have already been removed, use the API to check progress:

```
curl -sS "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq
```{{exec}}

Repeat the request after a few seconds until `status` is `successful`. The first execution takes longer while Kubernetes downloads the images. A successful response includes links to the application and stage-out logs. If the status is `failed`, inspect the message and logs before continuing.

Retrieve the results:

```
curl -sS "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID/results" \
  -o resize-results.json
jq . resize-results.json
```{{exec}}

The response is a GeoJSON `FeatureCollection` containing a STAC Item. Its `assets` entry gives the S3 location of the resized PNG. The logo is a demonstration image; the global bounding box is placeholder metadata, not a geographic footprint.

Download that asset using the configured MinIO client:

```
OUTPUT_URI=$(jq -r '.features[0].assets["logo6_med.original-resize"].href' resize-results.json)
mc cp "minio-local/${OUTPUT_URI#s3://}" resized.png
```{{exec}}

Download the original image and compare their dimensions with the `file` utility:

```
apt-get install -y file
curl -fsSL https://eoepca.org/media_portal/images/logo6_med.original.png -o original.png
file original.png resized.png
```{{exec}}

For this logo, `file` reports 822 × 162 pixels for the original and 411 × 81 pixels for the output: half the width and height. This verifies that the application processed the input and that its result was staged to object storage.

List the stored results, including their STAC metadata:

```
mc ls -r minio-local/eoepca/processing-results/
```{{exec}}

Keep the registered process and results so you can submit another execution with a different resize percentage.
