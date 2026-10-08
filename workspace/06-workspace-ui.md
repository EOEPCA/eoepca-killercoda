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

> NOTE that due to the proxying approach that is used by this tutorial environment, you will find that the navigation links within the Workspace UI will not work. This includes the link to open the Datalab session, as well as the `Editor` and `Data` links within the Datalab session. As an alternative, you should use the direct links provided in this tutorial to access the Datalab and its components.

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

Open the [Datalab]({{TRAFFIC_HOST1_91}}/) and sign in with the same credentials.

The gateway starts shortly after the deployment becomes ready. If the first request returns `502`, wait up to a minute and reload.

If the `Configuring session` cover remains visible, close it with the cross in the top-right corner to access the terminal and editor.

The dashboard provides a terminal, an editor and a file browser for the workspace buckets.

> NOTE that the `Data` file browser is not available in this Tutorial. It mounts the bucket over FUSE, which the Tutorial's container runtime does not support, so its `data-ws-eoepcauser-default` pod stays in `CrashLoopBackOff` with a mount propagation error. The terminal and editor are not affected. Use the `aws` client in the terminal instead.

## Access the VSCode Editor UI

Navigate to {{TRAFFIC_HOST1_92}} to access the editor. It is a VSCode-style interface with a file browser, editor and terminal. This editor is unique to the workspace and session, and is not shared with other users or sessions.

## Process the Observations

The commands in this section run in the Datalab **terminal**, not in the Tutorial shell.

The session already holds the workspace's own storage credentials, so the buckets need no configuration. List them:

```bash
aws s3 ls
aws s3 ls s3://ws-eoepcauser/
```

Both workspace buckets are listed, and `ws-eoepcauser` holds `observations.csv` from the previous step.

Download it and summarise the vegetation index across the sites:

```bash
aws s3 cp s3://ws-eoepcauser/observations.csv .
python3 - <<'PYTHON'
import csv
from statistics import mean

with open("observations.csv") as source:
    observations = list(csv.DictReader(source))

ndvi = [float(row["ndvi"]) for row in observations]
with open("ndvi-summary.csv", "w") as result:
    result.write(f"sites,{len(ndvi)}\n")
    result.write(f"mean_ndvi,{mean(ndvi):.2f}\n")
PYTHON
cat ndvi-summary.csv
```

The summary reports 3 sites and a mean NDVI of 0.50.

Write the result to the results bucket:

```bash
aws s3 cp ndvi-summary.csv s3://ws-eoepcauser-results/
aws s3 ls s3://ws-eoepcauser-results/
```

The result is stored in the workspace, not in the session, so it outlives the Datalab.

## Confirm the Result from the Tutorial Shell

Read the object back using the owner credentials configured in the previous step:

```bash
mc cat mystorage/ws-eoepcauser-results/ndvi-summary.csv
```{{exec}}

This returns the same summary the Datalab produced.

## Stop and Restart the Session

Stop the session from the Tutorial shell. Refresh the owner's token if the API returns `401` by repeating the token request at the start of this page.

```bash
curl --silent --show-error --fail -X PATCH \
  "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/workspaces/ws-${KEYCLOAK_TEST_USER}/sessions/default" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"state": "stopped"}' | jq
kubectl wait --for=delete \
  ns/ws-${KEYCLOAK_TEST_USER}-default ns/ws-${KEYCLOAK_TEST_USER}-default-vc --timeout=5m
mc cat mystorage/ws-eoepcauser-results/ndvi-summary.csv
```{{exec}}

The summary is still readable - it lives in the workspace bucket, not in the session.

Stopping deletes the session's namespaces, including the one holding its cluster, and the command above waits for them. Educates will fail a new session while the previous one is still terminating.

Start the session again:

```bash
curl --silent --show-error --fail -X PATCH \
  "${HTTP_SCHEME}://workspace-api.${INGRESS_HOST}/workspaces/ws-${KEYCLOAK_TEST_USER}/sessions/default" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"state": "started"}' | jq
kubectl -n ws-${KEYCLOAK_TEST_USER} wait --for=create \
  deployment/ws-${KEYCLOAK_TEST_USER}-default --timeout=2m
kubectl -n ws-${KEYCLOAK_TEST_USER} rollout status \
  deployment/ws-${KEYCLOAK_TEST_USER}-default --timeout=5m
```{{exec}}

Reopen the [Datalab]({{TRAFFIC_HOST1_91}}/). As on the first start, it may return `502` for a few seconds until the new session's gateway is running - reload until the dashboard appears. Then check what was kept, in its terminal:

```bash
ls ~
aws s3 cp s3://ws-eoepcauser-results/ndvi-summary.csv -
```

The files in the home directory are still there - it is kept on the session's persistent volume. The result in the bucket still reports 3 sites and a mean NDVI of 0.50.

## Dedicated Cluster

Each Datalab has its own vCluster. From the Datalab terminal:

```bash
kubectl get nodes
kubectl get namespaces
```

This is the workspace's own Kubernetes API. Only its default namespaces exist - none of the host cluster's, such as `workspace` or `iam`, are visible. Note the node's `VERSION`.

Deploy a workload into it:

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

The nginx welcome page is returned.

The vCluster schedules its pods on the host cluster, in the session's `-vc` namespace. Look at them from the Tutorial shell:

```bash
kubectl get nodes
kubectl -n ws-${KEYCLOAK_TEST_USER}-default-vc get pods
```{{exec}}

The host node reports a different `VERSION`. The `web` and `check` pods appear with names rewritten by the vCluster, next to its control plane, `my-vcluster-0`.

The `web` deployment stays in the workspace's cluster for further experimentation. Unlike the buckets and the home directory, the vCluster is recreated when the session stops and starts again.

## Keep the Session Available

The scheduled cleaner stops every session at 20:00 UTC. Remove it from this tutorial so the Datalab stays available for further work. Run this in the Tutorial shell:

```bash
kubectl delete -f workspace-cleanup/datalab-cleaner.yaml
```{{exec}}

The workspace, session and stored results are preserved.
