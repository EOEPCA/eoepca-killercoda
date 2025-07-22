At this point we need to configure the integration between SharingHub, MLFlow and Gitlab.

Gitlab is a pre-requisite for the MLOps Buildign Block, as it is used to manage data and experiments. In this tutorial, for simplicity, we are skipping the details on how to install a gitlab instance and we are using a local gitlab installation.

Before continuing, we need to be sure our local gitlab installation has started correctly, as it may take up to 10 minutes. To check your installation has started correctly you can run the following commands (which will terminate once the gitlab application has started)

```
while [[ "`curl -s -o /dev/null -w "%{http_code}" "{{TRAFFIC_HOST1_8080}}"`" != "302" ]]; do sleep 10; done
```{{exec}}

At this point we can tetrieve the GitLab `root`{{}} user password:

```bash
docker exec -it $(docker ps -qf "name=gitlab") sed -n 's|^Password: \(.*\)$|\1|p' /etc/gitlab/initial_root_password
```{{exec}}

and we need to create a GitLab OIDC application with redirect URIs.

To do so we can open the [local GitLab instance]({{TRAFFIC_HOST1_8080}}/admin/applications/new)

Log in with the `root` user and the password you retrieved above.

Fill in the form:

Name:
```
EOEPCA MLOps BB
```{{copy}}

Redirect URI: The HTTPS and HTTP url for the application, which you can obtain by running

```
#Generate URL for SharingHub authorization
{ echo "Copy the URLs below in the \"Redirect URI\" field";
  sed -e 's|^.*\(://.*-\)PORT\(\..*\)$|http\180\2/api/auth/login/callback|' /etc/killercoda/host;
  sed -e 's|^.*\(://.*-\)PORT\(\..*\)$|http\180\2/mlflow/auth/authorize|' /etc/killercoda/host;
} | cat
```{{exec}}

Scopes: `api`, `read_api`, `read_user`, `read_repository`, `write_repository`, `openid`, `profile`, `email`

And at last click *Save application*.

Then run this command to apply application credentials to the state. When prompted, enter the GitLab OIDC application ID and secret you just created:

```bash
bash utils/save-application-credentials-to-state.sh
```{{exec}}

Verify secrets were created:

```bash
kubectl -n sharinghub get secrets
```{{exec}}

You should see secrets for the mlflow and sharinghub as the following

```
mlflow-sharinghub            Opaque   1      5m33s
mlflow-sharinghub-gitlab     Opaque   2      5m38s
mlflow-sharinghub-postgres   Opaque   2      5m33s
mlflow-sharinghub-s3         Opaque   2      5m33s
sharinghub                   Opaque   1      5m33s
sharinghub-oidc              Opaque   2      5m38s
sharinghub-s3                Opaque   2      5m33s
```{{}}

