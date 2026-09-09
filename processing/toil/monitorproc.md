The application is now running. After a few seconds, the Celery log should show that Toil WES has received the request:

```
tail -n 15 ~ubuntu/celery.log
```{{exec}}

Toil then starts jobs in the HPC system. Check the HTCondor queue with:

```
condor_q -all
```{{exec}}

This example is small, so the queue may already be empty by the time you run the command.

Users monitor the processing status through the API:

```
curl --silent --show-error \
  "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" \
  | jq
```{{exec}}

The job progresses through `accepted` and `running`, and finishes with the `successful` state. Repeat the request until the status is `successful` - this example takes about a minute. The response also links to the WES workflow execution log, which contains the application output and the stage-out messages. If the status is `failed`, read that log before continuing.

Retrieve the results:

```
curl --silent --show-error \
  "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID/results" \
  | jq
```{{exec}}

The response is a STAC `FeatureCollection`. Its feature describes the output produced by the application, its `assets` name the generated PNG, and its `links` give the S3 location of the staged catalogue. The image is a demonstration input, so the global bounding box is placeholder metadata rather than a geographic footprint.

Toil staged those files into object storage under the job identifier:

```
mc ls --recursive minio-local/eoepca/$JOB_ID/
```{{exec}}

You should see the STAC catalogue, the STAC item and the resized PNG. Download the image:

```
mc cp minio-local/eoepca/$JOB_ID/processing-results/kubernetes-resize.png resized.png
```{{exec}}

Download the original image and compare their dimensions with the `file` utility:

```
apt-get install -y file
curl -fsSL https://raw.githubusercontent.com/github/explore/main/topics/kubernetes/kubernetes.png -o original.png
file original.png resized.png
```{{exec}}

`file` reports 288 × 288 pixels for the original and 144 × 144 for the output: half the width and height. This confirms that the application ran on the HPC cluster and that its result reached object storage.

The same files are visible in the [MinIO Console]({{TRAFFIC_HOST1_901}}/browser/eoepca), using the `eoepca`{{}} / `eoepcatest`{{}} credentials.

The process and its results are left in place, so you can submit another execution with a different resize percentage.
