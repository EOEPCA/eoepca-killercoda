## Configuration

Next, we'll run the configuration script.

This will configure the OpenEO building block with the following:

- **Ingress Host**: `eoepca.local`
- **Storage Class**: `standard`

```bash
bash configure-openeo.sh <<EOF
eoepca.local
standard
EOF
```{{exec}}

The script uses your input to generate the necessary configuration files for the deployment.
