
Before proceeding with the Resource Health building block deployment, we need first to configure it. 

Now we can run the configuration script `configure-resource-health.sh` provided in the EOEPCA deployment guide:

```
bash configure-resource-health.sh
```{{exec}}

The script will load the general EOEPCA configuration and move to the Resource Health building block specific configuration.

We will use the default internal cluster issuer:
```
eoepca-ca-clusterissuer
```{{exec}}

We will use the basic storage class provided in this sandbox. Note that, in an operational environment, you should use a reliable (and possibly redundant and backed up) storage class:
```
local-path
```{{exec}}

We do not need to update the domain, we will use what's already set:
```
no
```{{exec}}

For this demonstration, we will not be enabling OIDC authentication:
```
no
```{{exec}}

The configuration is now complete. You can verify the generated files:

```
ls -la generated-*.yaml
```{{exec}}

Let's have a quick look at the generated ingress configuration:

```
cat generated-ingress.yaml
```{{exec}}