## Prerequisites and Initial Setup

Clone the deployment-guide repository containing the necessary scripts and configurations.

```bash
git clone https://github.com/EOEPCA/deployment-guide -b release-2-jh
cd deployment-guide/scripts/processing/openeo-argo
```{{exec}}

Set up environment variables for the Killercoda environment:

```bash
http
nginx
eoepca.local
local-path
no
```

Validate prerequisites:

```bash
bash check-prerequisites.sh <<EOF
http
nginx
eoepca.local
local-path
no
EOF
```{{exec}}