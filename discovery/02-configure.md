Before proceeding with the Resource Discovery building block deployment, we need first to configure it. We can do it with the configuration script `configure-resource-discovery.sh` provided in the EOEPCA deployment guide.

```
bash configure-resource-discovery.sh
```{{exec}}

The script will load the general EOEPCA configuration and move to the Resource Discovery building block specific configuration.

We do not need to update domain and storage class, we will use what's already set, so we answer `no` to both questions:

```
no
no
```{{exec}}
