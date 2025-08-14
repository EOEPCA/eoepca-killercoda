## Prerequisites and Initial Setup

First, let's clone the deployment-guide repository which contains the necessary scripts.

```bash
git clone https://github.com/EOEPCA/deployment-guide
cd deployment-guide/scripts/processing/openeo
git checkout killercoda-jh-dask-openeo
```{{exec}}

Set up the environment variables for both Killercoda and local development:

Now run the prerequisite validation script:

```bash
bash check-prerequisites.sh <<EOF
http
nginx
eoepca.local
local-path
no
keycloak.eoepca.local
eoepca
EOF
```{{exec}}