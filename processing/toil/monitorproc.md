The application is now running. After a few seconds, the Celery log should show that Toil WES has received the request:

```
tail -n 15 ~ubuntu/celery.log
```{{exec}}

Toil will then start jobs in the HPC system. Check the HTCondor queue with:

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

The job progresses through states such as `accepted` and `running`, and should finish with the `successful` state. Poll every 30 seconds for at most ten minutes:

```
deadline=$((SECONDS + 600))
while (( SECONDS < deadline )); do
  JOB_STATUS=$(
    curl --fail --silent --show-error \
      "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" \
      | jq -er '.status'
  ) || break

  echo "status is $JOB_STATUS"
  case "$JOB_STATUS" in
    successful|failed|dismissed) break ;;
  esac
  sleep 10
done
```{{exec}}

Access the final job status, including any processing message:

```
curl --silent --show-error \
  "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" \
  | jq
```{{exec}}

The staged result is also available directly from object storage:

```
mc ls --recursive minio-local/eoepca/$JOB_ID/
```{{exec}}

You should see the generated catalog and processing result files under the job identifier.
