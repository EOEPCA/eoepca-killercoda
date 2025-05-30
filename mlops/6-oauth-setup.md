
## Configuring GitLab OAuth for SharingHub

1. Retrieve GitLab root password:

```bash
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab --template={{.data.password}} | base64 -d
```{{exec}}

  

2. Log into GitLab at https://gitlab.eoepca.local with username root.
3. Go to Admin Area → Applications → Add New Application.
4. Configure as:

- Name: SharingHub
- Redirect URI: https://sharinghub.eoepca.local/api/auth/login/callback
- Scopes: Select api, read_api, read_user, read_repository, write_repository, openid, profile, email.

5. Save credentials and run:

```bash
bash utils/save-application-credentials-to-state.sh
```
