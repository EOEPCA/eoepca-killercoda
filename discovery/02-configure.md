Before proceeding with the Resource Discovery building block deployment, we need first to configure it. We can do it with the configuration script `configure-resource-discovery.sh` provided in the EOEPCA deployment guide.

```
bash configure-resource-discovery.sh
```{{exec}}

The script will load the general EOEPCA configuration and move to the Resource Discovery building block specific configuration.

Aside from not updating the domain, we specify a storage class, disable authorization for the protected catalogue endpoint used for write access and disable TLS:

```
no
local-path
yes
no
```{{exec}}
