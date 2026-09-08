# End-to-End Datacube Access

IAM, Workspace, Data Access and a Python environment are set up for the draft cloud-fraction notebook. Login, S3 storage, STAC registration and a small raster read have been tested. Converting the notebook into scenario steps is the next task.

## Start

Requires Localcoda with Sysbox and `/dev/fuse`.

From `eoepca-killercoda`:

```bash
LOCALCODA_ROOT=../localcoda EXT_DOMAIN_NAME=release-21.deploybox.co.uk bash run.sh end-to-end
```

Once background setup finishes, run in the tutorial terminal:

```bash
bash /tmp/assets/setup-environment.sh
source ~/datacube-venv/bin/activate
```

Fresh deployments need the accompanying deployment-guide ingress-template fix; it is already applied in the running instance.

## Access

Browser links are in the scenario's Explore step. Both `eoepcauser` and `eoepcaadmin` use password `eoepcapassword`.

Inside the tutorial container:

- Workspace API: `http://workspace-api.eoepca.local/workspaces`
- STAC API: `http://eoapi.eoepca.local/stac`
- IAM issuer: `OIDC_ISSUER_URL` in `~/.eoepca/state`
- Public clients: `workspace-api` and `eoapi`, using PKCE without a client secret

The running instance has workspace `ws-datacube`, owned by `eoepcauser`, and sample collection `datacube-environment-check`. Update the notebook's endpoints and account settings before using it.

Harvester and openEO services are not included. Datacube Access itself has no service to deploy.

## Versions

| Component | Version |
| --- | --- |
| IAM chart | `2.1.0-dev12` |
| Workspace API chart / image | `2.2.2` / `v2.2.0` |
| Workspace CSI-rclone, Educates and Pipeline charts | `2.2.0` |
| PostgreSQL operator | `5.8.8` |
| eoAPI chart | `0.13.1` |
| STAC API / authentication proxy images | `6.2.2` / `v1.2.0` |
| STAC Manager chart / image | `1.0.3` |
