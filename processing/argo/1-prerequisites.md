we need to install a couple of essential tools: **Skaffold** for automating our deployments and the **MinIO Client (`mc`)** for interacting with our S3 object storage.

First, let's install Skaffold. This command downloads the binary and moves it into path.

```bash
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
install skaffold /usr/local/bin/
```{{exec}}

Next, we'll install the MinIO client.

```bash
curl -sL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc && \
chmod +x /usr/local/bin/mc
```{{exec}}

Finally, let's create a dedicated Kubernetes namespac.

```bash
kubectl create namespace ns1
```{{exec}}

