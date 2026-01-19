
Before proceeding with the Data Access building block deployment, we need to configure it.

Now we can run the configuration script `configure-data-access.sh` provided in the EOEPCA deployment guide:

```
bash configure-data-access.sh
```{{exec}}

The script will load the general EOEPCA configuration and move to the Data Access building block specific configuration.

```
eoepca.local
```{{exec}}

We will use the basic storage class provided in this sandbox:
```
local-path
```{{exec}}

For the S3 host, we use our local MinIO instance:
```
minio.eoepca.local
```{{exec}}

Enter the S3 access key:
```
eoepca
```{{exec}}

Enter the S3 secret key:
```
eoepcatest
```{{exec}}

For the S3 endpoint used by eoAPI services:
```
minio.eoepca.local
```{{exec}}

We will use the internal PostgreSQL (managed by the Crunchy Postgres Operator):
```
no
```{{exec}}

Number of PostgreSQL replicas (1 is sufficient for demo):
```
1
```{{exec}}

PostgreSQL storage size:
```
1Gi
```{{exec}}

For this demonstration, we will not be enabling IAM/Keycloak integration:
```
no
```{{exec}}

Enable STAC transactions extension (allows creating/updating collections):
```
yes
```{{exec}}

We will not enable the CloudEvents notifier for this demo:
```
no
```{{exec}}

The configuration is now complete. You can verify the generated files:

```
head -50 eoapi/generated-values.yaml
```{{exec}}
