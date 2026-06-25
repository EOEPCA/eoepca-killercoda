## Prerequisites and Initial Setup

Download the EOEPCA Deployment Guide release used by this workshop, then enter the OpenEO ArgoWorkflows scripts directory:

```bash
cd ~
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0 \
  | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
cd deployment-guide/scripts/processing/openeo-argo
```{{exec}}

The Localcoda setup has already stored the HTTP scheme and workshop domain in `~/.eoepca/state`. Complete the remaining first-time settings and run the prerequisite checks:

```bash
bash check-prerequisites.sh <<EOF
nginx
n
local-path
no
EOF
```{{exec}}

These answers select the NGINX ingress class, keep `eoepca.local`, use the k3s `local-path` storage class, and disable cert-manager for this HTTP-only workshop.

Confirm the saved shared settings:

```bash
cat ~/.eoepca/state
```{{exec}}
