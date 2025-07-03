## Prerequisites and Initial Setup

First, let's clone the `deployment-guide` repository which contains the necessary scripts.

```bash
git clone https://github.com/EOEPCA/deployment-guide -b killercoda-jh-changes
cd deployment-guide/scripts/processing/openeo
```{{exec}}

```bash
export INGRESS_HOST=$(echo "{{TRAFFIC_HOST1_30080}}" | sed -E 's~^https?://~~;s~/.*~~')
```{{exec}}

Now, run the prerequisite validation script to ensure your environment is set up correctly.

```bash
bash check-prerequisites.sh <<EOF
http
nginx
no
local-path
no
EOF
```{{exec}}
