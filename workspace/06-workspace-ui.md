
Each new Workspace has its own Web UI for:
* managing workspace resources
* datalab environment providing:
  * terminal access to dedicated vCluster (workspace-dedicated Kubernetes cluster)
  * VSCode-style editor
  * file-browser for buckets

## Access the Workspace UI

The Workspace UI is accessible under the endpoint `/workspaces/ws-<workspace-name>` of the workspace-api service.

Open the [Workspace UI]({{TRAFFIC_HOST1_81}}/workspaces/ws-eoepcauser) for `eoepcauser`:
* Username: `eoepcauser`
* Password: `eoepcapassword`
