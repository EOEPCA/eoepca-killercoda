# End-to-End Datacube Access

Scaffolding for a Localcoda scenario that reproduces the
[E2E External Data Registration notebook](https://github.com/EOEPCA/demo/blob/main/demoroot/notebooks/08-1%20tb%20E2E%20External%20Data%20Registration%20CF.ipynb):
fetch third-party EO data, reshape it to the Datacube Access BB's STAC Best Practices
convention, save it to a Workspace, register it with the Data Access BB's STAC API, and read
it back as an analysis-ready cube.

Datacube Access itself has no service to deploy - it's the metadata convention the notebook
applies when it registers data. Only IAM, Workspace and Data Access (eoAPI) get deployed here.

## Status: pre-baking a warm image doesn't work - Building Blocks are deployed live as step 1

A pre-baked image (all BBs already deployed, to skip the ~30-45 minute wait) was tried and
doesn't work: `docker commit` can't capture k3s's data (sysbox mounts it outside the
container's overlay layer), and even after tarring/restoring it manually, no new pod can ever
start again:

```
failed to create containerd task: ... runc create failed: unable to start container process:
error during container init: open sysctl net.ipv4.ip_unprivileged_port_start file: unsafe
procfs detected: openat2 /proc/./sys/net/ipv4/ip_unprivileged_port_start: invalid cross-device link
```

Not restore-specific - reproduces from a plain `systemctl stop k3s && systemctl start k3s`
inside a live container, no snapshot involved. `hostNetwork: true` pods (e.g. `apisix`) are
unaffected, since the failing sysctl is only touched during per-pod network namespace setup.
Looks like a sysbox + runc interaction (sysbox's virtualised `/proc` vs runc's "unsafe procfs"
hardening not handling a second containerd instance's netns setup) - not fixable from this
scenario's scripts; would need a different sysbox/runc pin in the base image, or CRIU-based
checkpoint/restore instead of a plain tar snapshot.

So `index.json` points at the plain base image, and step 1 (`01-setup.md`) deploys IAM,
Workspace and Data Access live via `setup-environment.sh` - same sequence `build-image.sh`
uses, run directly in the scenario's own shell instead of a throwaway container.

## Running build-image.sh

```bash
bash build-image.sh
```

Requires sysbox and a `deployment-guide` checkout on `release-2.1` at `../../deployment-guide`.
Deploys IAM, Workspace and Data Access into a throwaway container (`docker rm`'d at the end) -
useful for testing the deploy sequence in isolation. Builds the plain Localcoda sysbox/k3s base
image locally if not already cached, instead of pulling `spinto/localcoda-sysbox-k3s` from
Docker Hub. The final third (snapshotting k3s state, `docker commit`) doesn't produce a usable
image - see Status above. `setup-environment.sh` is the same deploy sequence without the
container lifecycle wrapper, for running as this scenario's own step 1.

## What it deploys

| Building Block | Notes |
|---|---|
| IAM | Keycloak realm `eoepca`, users `eoepcauser`/`eoepcaadmin` (password `eoepcapassword`) |
| Workspace | `workspace-api` client, no pre-created workspace |
| Data Access | eoAPI with IAM enabled (`eoapi` client), STAC transactions on, titiler-openeo skipped |

A sample datacube-ready STAC collection (`sentinel-2-datacube`) is loaded into eoAPI at the end.

## Known limitations and bugs found along the way

- **titiler-openeo is skipped.** `ghcr.io/sentinel-hub/titiler-openeo` has been broken on all
  tags since 2026-08-23 (upstream registry cleanup, not an EOEPCA bug). Only the `/openeo/`
  path under eoAPI is affected.
- **`data-access/iam/iam-template.yaml`'s `ClientOptionalScopes` resource doesn't apply.** Needs
  a CRD (`clientoptionalscopes.openidclient.keycloak.m.crossplane.io`) not present in the
  Crossplane Keycloak provider version `commons/assets/crossplane` pins (`v2.24.1`). Only the
  "email" optional scope on the `eoapi` client is skipped; everything else in that file applies.
- **`deployment-guide/scripts/datacube-access/collections/ingest.sh` doesn't work as
  documented.** It `apt install`s inside the `eoapi-raster` pod (uid 1000, can't write
  `/var/lib/apt`), and `pip install -U pypgstac` pulls PyPI's `0.9.12`, older than the pgstac
  schema the eoapi chart migrates to (`v0.10.0`) - item loads fail with `function
  partition_catalog_meta does not exist`. Worked around by running `pypgstac` from a throwaway
  pod using the same `pgstac-pypgstac:v0.10.0` image the chart's own migration job uses.
