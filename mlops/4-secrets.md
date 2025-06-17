## Set up a GitLab OIDC Application. 

Retrieve the GitLab password:

```bash
docker exec -it $(docker ps -qf "name=gitlab") cat /etc/gitlab/initial_root_password
```

Create the GitLab OIDC application with redirect URIs:
{{TRAFFIC_HOST1_30080}}/api/auth/login/callback

```bash
export GITLAB_APP_ID=""
export GITLAB_APP_SECRET=""
```

```bash
kubectl create namespace sharinghub
bash apply-secrets.sh
```{{exec}}

Then run this to apply application credentials to the state:

```bash
bash utils/save-application-credentials-to-state.sh <<EOF
n
n
EOF
```{{exec}}

Verify secrets were created:

```bash
kubectl -n sharinghub get secrets
```{{exec}}

You should see secrets for the mlflow and sharinghub.