## Set up a GitLab OIDC Application. 

Retrieve the GitLab password:

```bash
docker exec -it $(docker ps -qf "name=gitlab") cat /etc/gitlab/initial_root_password
```{{exec}}

## Create the GitLab OIDC application with redirect URIs:

1. Navigate to [GitLab]({{TRAFFIC_HOST1_8080}}/admin/applications/new)
2. Log in with the root user and the password you retrieved.
3. Fill in the form:
   - **Name**: SharingHub
   - **Redirect URI** (use both http and https): 
```plaintext
{{TRAFFIC_HOST1_30080}}/api/auth/login/callback
```
   - **Scopes**: `api`, `read_api`, `read_user`, `read_repository`, `openid`, `profile`, `email`
6. Click **Save application**.

Then run this to apply application credentials to the state. When prompted, enter the GitLab OIDC application ID and secret you just created:

```bash
bash apply-secrets.sh
bash utils/save-application-credentials-to-state.sh
```{{exec}}

Verify secrets were created:

```bash
kubectl -n sharinghub get secrets
```{{exec}}

You should see secrets for the mlflow and sharinghub.