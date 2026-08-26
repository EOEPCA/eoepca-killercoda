Before proceeding with the Workspace building block deployment, we need first to configure it. We can do it with the configuration script `configure-workspace.sh` provided in the EOEPCA deployment guide.

```
bash configure-workspace.sh
```{{exec}}

The shared domain/storage/TLS questions were already answered in the prerequisites step, so
this script only asks about settings specific to Workspace.

* S3 endpoint, region, access key and secret key are already well configured for MinIO **->**
```
no
no
no
no
```{{exec}}
* Client ID for Workspace Pipeline **->** `workspace-pipeline`{{exec}}
* Client ID for Workspace API **->** `workspace-api`{{exec}}
* Enable authentication via IAM **->** `true`{{exec}}
* The test users are already well configured **->**
```
no
no
no
```{{exec}}
