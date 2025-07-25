Now it's time to deploy our core platform, which consists of **Argo Workflows** and a **MinIO S3 server**. We'll use a Git repository that has this all pre-configured for Skaffold.

Let's clone the repository and move into the directory.

```bash
git clone https://github.com/fabricebrito/dev-platform-argo-workflows.git
cd dev-platform-argo-workflows
```{{exec}}

This directory contains all the Kubernetes manifests and a `skaffold.yaml` file that tells Skaffold how to deploy them.

```bash
skaffold run
```{{exec}}

This will take a minute or two as Kubernetes pulls the necessary container images. Once it's done, we'll have Argo and MinIO running in our cluster.

Wait until Skaffold has finished before continuing. 