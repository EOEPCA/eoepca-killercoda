The application is now running. After a few seconds, its dedicated namespace is created. Calrissian automatically removes this namespace after the execution finishes, so a fast job may already be cleaned up when you run this command:

```
kubectl get namespace "$JOB_NAMESPACE" 2>/dev/null ||
  echo "The execution namespace has already been cleaned up."
```{{exec}}

It may take another few seconds before the namespace is populated with the Kubernetes job pods:

```
if kubectl get namespace "$JOB_NAMESPACE" >/dev/null 2>&1; then
  kubectl get pods -n "$JOB_NAMESPACE"
else
  echo "No active execution pods (the job may already be complete)."
fi
```{{exec}}

The processing status is available from the API:

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq
```{{exec}}

When the job completes successfully, the API status becomes `successful`.

The first execution takes longer because Kubernetes must download the application images. The following bounded loop checks every 30 seconds for up to 10 minutes:

```
for attempt in {1..20}; do
  JOB_STATUS=$(curl -s -S \
    "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" |
    jq -r '.status')
  echo "Job status: $JOB_STATUS"
  kubectl get pods -n "$JOB_NAMESPACE" 2>/dev/null || true

  case "$JOB_STATUS" in
    successful|failed|dismissed) break ;;
  esac

  sleep 30
done

if [[ "$JOB_STATUS" != "successful" ]]; then
  echo "Job did not complete successfully (status: $JOB_STATUS)"
  kubectl get events -n "$JOB_NAMESPACE" \
    --sort-by=.lastTimestamp | tail -20
  false
fi
```{{exec}}

We can now access the status document, which includes the final status and links to the processing logs:

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID" | jq
```{{exec}}

For a successful job, the results endpoint returns a STAC Collection describing the output:

```
curl -s -S "http://zoo.eoepca.local/test/ogc-api/jobs/$JOB_ID/results" | jq
```{{exec}}

The STAC metadata and resized image are also available directly from object storage:

```
mc ls -r minio-local/eoepca
```{{exec}}
