To interact with our newly deployed platform, we need to access the **Argo Server** and **MinIO** services from our terminal. The easiest way to do this is using `kubectl port-forward`.

Let's forward the MinIO service running on port 9000 inside the cluster to port 9000 on our local machine. We'll run this in the background using `&`.


```bash
nohup kubectl port-forward svc/minio -n ns1 9000:9000 9001:9001 > minio-port-forward.log 2>&1 &
nohup kubectl port-forward svc/argo-server -n ns1 2746:2746 > argo-port-forward.log 2>&1 &
```{{exec}}

Now that we can access MinIO, let's configure our `mc` client to connect to it.

```bash
mc alias set local-minio http://127.0.0.1:9000 minio-admin minio-admin
```{{exec}}

Finally, we need to create the S3 buckets that our workflow template expects. The `workflows` bucket is for temporary workflow data, and the `results` bucket is where our final output will be stored.

```bash
mc mb local-minio/workflows
```{{exec}}

```bash
mc mb local-minio/results
```{{exec}}

Our storage is configured and we're ready to build our processing service.