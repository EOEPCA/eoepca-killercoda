## Prerequisites and Initial Setup

First, let's clone the `deployment-guide` repository which contains the necessary scripts.

```bash
git clone https://github.com/EOEPCA/deployment-guide
cd deployment-guide/scripts/processing/openeo
```{{exec}}

Now, run the prerequisite validation script to ensure your environment is set up correctly.

```bash
bash check-prerequisites.sh <<EOF
http
nginx
eoepca.local
standard
no
EOF
```{{exec}}
