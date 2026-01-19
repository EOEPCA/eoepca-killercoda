
Each new Workspace has its own Web UI for:
* managing workspace resources
* datalab environment providing:
  * terminal access to dedicated vCluster (workspace-dedicated Kubernetes cluster)
  * VSCode-style editor
  * file-browser for buckets

## Access the Workspace UI

The Workspace UI is accessible under the endpoint `/workspaces/ws-<workspace-name>` of the workspace-api service.

> NOTE that whilst the Tutorial is able to provide access to the user's `Home` page of the Workspace UI, due to constraints of this Tutorial environment, it is not possible to successfully proxy access to the UI for the `Datalabs` dashboard.

Access to the Workspace UI requires authentication using the credentials of a user that has been granted access to the workspace - in this case the `eoepcauser` user that is the owner of the `eoepcauser` workspace.

Open the [Workspace UI]({{TRAFFIC_HOST1_81}}/workspaces/ws-eoepcauser) for `eoepcauser`:
* Username: `eoepcauser`
* Password: `eoepcapassword`
