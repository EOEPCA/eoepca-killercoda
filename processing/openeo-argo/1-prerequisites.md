## Prerequisites and Initial Setup

Clone the **release-2.1** branch of the EOEPCA Deployment Guide used by this workshop, then enter the OpenEO ArgoWorkflows scripts directory:

<!-- TODO(release-2.1): once the eoepca-2.1 tag is published, revert this step to the tarball
     download: curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.1 | tar zx
     --transform 's|^EOEPCA[^/]*|deployment-guide|' -->
```bash
cd ~
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
cd deployment-guide/scripts/processing/openeo-argo
```{{exec}}

The Localcoda setup has already deployed the shared IAM (Keycloak/Crossplane) and APISIX ingress used by this tutorial, and stored the HTTP scheme and workshop domain in `~/.eoepca/state`. Run the prerequisite checks, which also complete the remaining one-time shared settings:

```bash
bash check-prerequisites.sh <<EOF
n
local-path
no
EOF
```{{exec}}

These answers keep the domain `eoepca.local` (already set), use the k3s `local-path` StorageClass for regular persistent volumes, and disable cert-manager for this HTTP-only workshop. The script should finish with `All prerequisites are met`, including a check that the `standard` StorageClass supports `ReadWriteMany`, which the shared job workspace needs.

Confirm the saved shared settings:

```bash
cat ~/.eoepca/state
```{{exec}}

If you want to learn more about these settings, follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Prerequisites</a> tutorial.
