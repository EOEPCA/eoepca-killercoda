Before proceeding with the Resource Registration building block deployment, we need first to configure it. We can do it with the configuration script `configure-resource-registration.sh` provided in the EOEPCA deployment guide.

```
bash configure-resource-registration.sh
```{{exec}}

The script will load the general EOEPCA configuration and move to the Resource Registration building block specific configuration.

We do not need to update domain or storage classes, we will use what's already set, so we answer `no` to the first three questions. We use eoepca/eoepca as the username and password for the Flowable workflow engine used for harvesting and opt not to use OIDC authentication as we have not installed the IAM building block.

```
n
n
n
eoepca
eoepca
no
no
```{{exec}}


We must also store the Flowable username and password into a secret. Here, we also choose not to set up harvesting of Landsat or Sentinel data as these require credentials and approval from USGS/CDSE.

```
echo "n
n" | bash apply-secrets.sh
```{{exec}}
