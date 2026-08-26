Before deploying the Operations building block, we need to configure it. We do this with the configuration script `configure-operations.sh` provided in the EOEPCA deployment guide.

```
bash configure-operations.sh
```{{exec}}

The script first asks for the Prometheus storage settings. Accept the defaults:

Storage size for Prometheus TSDB:
```
50Gi
```{{exec}}

Metrics retention period:
```
30d
```{{exec}}

Next it asks for the S3-compatible object store used by Loki to hold log chunks. The tutorial environment already deployed a local MinIO instance and set these values for you, so answer `n`{{}} to keep each one:

Host URL for the S3-compatible object store: (already set)
```
n
```{{exec}}

Bucket name for Loki chunk storage — this is a fresh question, since the tutorial environment only pre-seeds the shared MinIO connection details, not a bucket name. A `logging` bucket has already been created for you, so use that:
```
logging
```{{exec}}

Access key for S3 storage: (already set)
```
n
```{{exec}}

Secret key for S3 storage: (already set)
```
n
```{{exec}}

Log retention period in hours:
```
168
```{{exec}}

Enable IAM/Keycloak integration? This tutorial deploys Operations in its simpler default mode — local admin login for Grafana, no authentication for Keep:
```
no
```{{exec}}

Deploy STAC-specific SLO alerts? These only produce data once the Data Access BB is also deployed with its APISIX prometheus plugin enabled, which is outside the scope of this tutorial:
```
no
```{{exec}}

The script renders the Helm values and Kubernetes manifests used in the next step from these answers.
