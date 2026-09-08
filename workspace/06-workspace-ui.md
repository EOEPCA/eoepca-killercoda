Each Workspace has its own Web UI for:
* managing workspace resources
* datalab environment providing:
  * terminal access to dedicated vCluster (workspace-dedicated Kubernetes cluster)
  * VSCode-style editor
  * file-browser for buckets

## Access the Workspace UI

The Workspace UI is accessible under the endpoint `/workspaces/ws-<workspace-name>` of the workspace-api service.

Access to the Workspace UI requires authentication using the credentials of a user that has been granted access to the workspace - in this case the `eoepcauser` user that is the owner of the `eoepcauser` workspace.

Open the [Workspace UI]({{TRAFFIC_HOST1_81}}/workspaces/ws-eoepcauser) for `eoepcauser`:
* Username: `eoepcauser`
* Password: `eoepcapassword`

## Start the Datalab Session

Each workspace is created with a `default` Datalab session, initially stopped. List it through the Workspace API:

```bash
source ~/.eoepca/state
ACCESS_TOKEN=$(
  curl --silent --show-error --fail \
    "${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/token" \
    -d "username=${KEYCLOAK_TEST_USER}" \
    --data-urlencode "password=${KEYCLOAK_TEST_PASSWORD}" \
    -d "grant_type=password" \
    -d "client_id=${WORKSPACE_API_CLIENT_ID}" \
    | jq -r '.access_token'
)
curl --silent --show-error \
  "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/workspaces/ws-${KEYCLOAK_TEST_USER}/sessions" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" | jq
```{{exec}}

The `default` session is reported with `"state": "stopped"`. Start it:

```bash
curl --silent --show-error -X PATCH \
  "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/workspaces/ws-${KEYCLOAK_TEST_USER}/sessions/default" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"state": "started"}' | jq
```{{exec}}

Wait for the session workload to come up:

```bash
kubectl -n ws-${KEYCLOAK_TEST_USER} wait --for=create \
  deployment/ws-${KEYCLOAK_TEST_USER}-default --timeout=2m
kubectl -n ws-${KEYCLOAK_TEST_USER} rollout status \
  deployment/ws-${KEYCLOAK_TEST_USER}-default --timeout=5m
```{{exec}}

## Open the Datalab

Open `Datalab (default)` in the Workspace UI's `Links` section, or use the [Datalab link]({{TRAFFIC_HOST1_91}}/). Sign in with the same credentials.

The gateway starts shortly after the deployment becomes ready. If the first request returns `502`, wait a few seconds and reload.

If the `Configuring session` cover remains visible, close it with the cross in the top-right corner to access the terminal and editor.

The dashboard provides a terminal, an editor and a file browser for the workspace buckets.

## Process the Observations

The commands in this section run in the Datalab **terminal**, not in the Tutorial shell.

The session already holds the workspace's own storage credentials, so the bucket needs no configuration. List it:

```bash
aws s3 ls s3://ws-eoepcauser/
```

`observations.csv`, uploaded in the previous step, is listed.

Download it and summarise the vegetation index across the sites:

```bash
aws s3 cp s3://ws-eoepcauser/observations.csv .
awk -F, 'NR>1 { total += $2; n++ } END { printf "sites,%d\nmean_ndvi,%.2f\n", n, total/n }' \
  observations.csv > ndvi-summary.csv
cat ndvi-summary.csv
```

The summary reports 3 sites and a mean NDVI of 0.50.

Write the result back to the workspace bucket:

```bash
aws s3 cp ndvi-summary.csv s3://ws-eoepcauser/
aws s3 ls s3://ws-eoepcauser/
```

Both objects are now in the bucket. The result is stored in the workspace, not in the session, so it outlives the Datalab.

## Confirm the Result from the Tutorial Shell

Read the object back using the owner credentials configured in the previous step:

```bash
mc cat mystorage/ws-eoepcauser/ndvi-summary.csv
```{{exec}}

This returns the same summary the Datalab produced.

## Dedicated Cluster

Each Datalab has its own vCluster. From the Datalab terminal:

```bash
kubectl get nodes
```

The node belongs to the workspace's own cluster, not the host cluster - workloads deployed here are isolated from other workspaces.

Deploy one:

```bash
kubectl create deployment web --image=nginx:alpine
kubectl expose deployment web --port=80
kubectl rollout status deployment/web --timeout=3m
```

Call the service from a one-shot pod in the same cluster:

```bash
kubectl run check --image=curlimages/curl --restart=Never -- curl -sS http://web
kubectl wait --for=jsonpath='{.status.phase}'=Succeeded pod/check --timeout=2m
kubectl logs check
```

The nginx welcome page is returned. The `web` deployment stays in the workspace's cluster for further experimentation.

> NOTE that the `Data` file browser is not available in this Tutorial. It mounts the bucket over FUSE, which the Tutorial's container runtime does not support. Use the `aws` client in the terminal, as above.

## Keep the Session Available

The scheduled cleaner stops every session at 20:00 UTC. Remove it from this tutorial so the Datalab stays available for further work. Run this in the Tutorial shell:

```bash
kubectl delete -f workspace-cleanup/datalab-cleaner.yaml
```{{exec}}

The workspace, session and stored results are preserved.
