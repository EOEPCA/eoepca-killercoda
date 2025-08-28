Now let's expose our services for interaction. We'll use kubectl port-forward to make them accessible locally.

Set up port forwarding for all services:

```bash
# Kill any existing port forwards
killall kubectl 2>/dev/null || true

# Port forward for ZOO API (run in background)
kubectl port-forward -n ns1 svc/zoo-project-dru-service 8080:80 &

# Port forward for MinIO
kubectl port-forward -n ns1 svc/s3-service 9000:9000 9001:9001 &

# Port forward for Argo UI
kubectl port-forward -n ns1 svc/argo-server 2746:2746 &

# Wait for port forwarding to establish
sleep 3
```{{exec}}

Configure MinIO client and verify buckets:

```bash
# Configure mc client
mc alias set local-minio http://127.0.0.1:9000 minio-admin minio-secret-password

mc mb local-minio/eoepca 2>/dev/null || true
mc mb local-minio/results 2>/dev/null || true
mc mb local-minio/argo-artifacts 2>/dev/null || true

# List buckets (should already exist)
mc ls local-minio/
```{{exec}}

Test the OGC API is accessible:

```bash
# Test the root endpoint
curl -s http://localhost:8080/ | head -10

# Test the OGC API endpoint
curl -s http://localhost:8080/ogc-api/ | jq '.title'

# List processes (should show "echo" process by default)
curl -s http://localhost:8080/ogc-api/processes | jq '.processes[].id'
```{{exec}}

You should now have:
- **OGC API**: http://localhost:8080/ogc-api/
- **Argo UI**: http://localhost:2746
- **MinIO Console**: http://localhost:9001 (login: minio-admin/minio-secret-password)