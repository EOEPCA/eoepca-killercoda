## Deploying GitLab

Deploy GitLab to manage repositories and provide OAuth authentication for SharingHub:

```bash
helm upgrade -i gitlab gitlab/gitlab \
  --version 8.1.8 \
  --namespace gitlab \
  --create-namespace \
  --values gitlab/generated-values.yaml
````

### Checking GitLab Deployment

Wait for pods to start, it can take up to 10 minutes:

```bash
kubectl get pods -n gitlab
```

Once all GitLab pods are running, fetch the initial admin password:

```bash
kubectl get secret gitlab-gitlab-initial-root-password \
  --template={{.data.password}} -n gitlab | base64 -d
```

Access GitLab at `https://gitlab.eoepca.local`.
