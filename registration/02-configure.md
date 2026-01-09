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


We must also store the Flowable username and password into a secret.

```
bash apply-secrets.sh
```{{exec}}

If you wish to set up harvesting of a small sample of Landsat data you'll need credentials for the [USGS Machine-to-Machine (M2M)](https://m2m.cr.usgs.gov/) API:

* Register for a free account at USGS (click on 'Login' in the link above and create a new account)
* Create an application token from your profile page at <https://ers.cr.usgs.gov/>, specifying the M2M API scope
* At the prompt displayed now, say `y` to enable Landsat harvesting and enter these credentials when asked.

If you do not wish to set up Landsat harvesting say `n`. You can rerun the tutorial from here to set it up later.

Next, you will be asked if you wish to set up harvesting for a small sample of Sentinel 2 data. You will need credentials from the Copernicus Data Space Ecosystem. Say `n` if you do not wish to set this up.
