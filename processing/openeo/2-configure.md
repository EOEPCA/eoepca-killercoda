## Configuration

Next, we'll run the configuration script.

This will configure the OpenEO building block with the following:

```bash
export INGRESS_HOST=$(echo "{{TRAFFIC_HOST1_30080}}" | sed -E 's~^https?://~~;s~/.*~~')
```{{exec}}

```bash
bash configure-openeo.sh <<EOF
no
local-path
no
EOF
```{{exec}}

The script uses your input to generate the necessary configuration files for the deployment.
