Before proceeding with the Workspace building block deployment, we need first to configure it. We can do it with the configuration script `configure-workspace.sh` provided in the EOEPCA deployment guide.

```
bash configure-workspace.sh
```{{exec}}

The script will load the general EOEPCA configuration and move to the Workspace building block specific configuration:
* `INGRESS_HOST` is already correctly set as `eoepca.local` **->** `no`{{exec}}
* Automated certificate issuance is not required **->** `no`{{exec}}
* S3 endpoint is already well configured for MinIO **->**
```
no
no
no
no
```{{exec}}
* Enable authentication via IAM **->** `true`{{exec}}
* Client ID for Workspace API **->** `workspace-api`{{exec}}
* Client ID for Workspace Pipeline **->** `workspace-pipeline`{{exec}}
* The test users are already well configured **->**
```
no
no
no
```{{exec}}
