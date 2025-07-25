To interact with our newly deployed platform, we need to access the **Argo Server** and **MinIO** services from our terminal. The easiest way to do this is using `kubectl port-forward`.

We must run these in separate tabs, as the port-forwarding is an active process that is most stable in a dedicated terminal session.

In one tab run:

```bash
kubectl port-forward svc/minio -n ns1 9000:9000 9001:9001
```{{exec}}

In another tab run:

```bash
kubectl port-forward svc/argo-server -n ns1 2746:2746
```{{exec}}

Now open the third tab. Where we will continue with our setup, leave the first two tabs running in the background.

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