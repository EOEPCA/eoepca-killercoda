
As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, download and extract the EOEPCA Deployment Guide:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc3 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

Navigate to the Resource Discovery deployment scripts:

```
cd deployment-guide/scripts/resource-discovery
```{{exec}}

### Check Prerequisites

Run the prerequisites check:

```
bash check-prerequisites.sh
```{{exec}}

Select the ingress controller:
```
nginx
```{{exec}}

Enter the top-level domain:
```
eoepca.local
```{{exec}}

Storage class for persistent data:
```
local-path
```{{exec}}

Certificate generation (not needed for this tutorial):
```
no
```{{exec}}

All prerequisites should now be met.