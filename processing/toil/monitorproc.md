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

The job progresses through `accepted` and `running`, and finishes with the `successful` state. Repeat the request until the status is `successful` - this example takes about a minute.

The response also links to the WES workflow execution log. This is the record of the run on the HPC side, and the place to look if the status is `failed`:

```
curl --silent --show-error \
  "http://zoo.eoepca.local/test/temp/convert-url-${JOB_ID}_job.log" \
  | tail -n 25
```{{exec}}

The last lines show the stage-out step uploading the application output to `s3://eoepca/`, followed by `Finished toil run successfully`. The application itself ran earlier in the log, in an HTCondor slot on the HPC environment.
