First, we'll install the MinIO client for managing our object storage:

```bash
curl -sL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && \
chmod +x /usr/local/bin/mc
```{{exec}}

create a dedicated namespace for our deployment. If this fails, wait a moment for Kubernetes to be ready and try again:

```bash
kubectl create namespace ns1
```{{exec}}

Great! Our prerequisites are ready. Let's move on to deploying the platform.