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

The same files are visible in the [MinIO Console]({{TRAFFIC_HOST1_901}}/browser/eoepca), using the `eoepca`{{}} / `eoepcatest`{{}} credentials.
