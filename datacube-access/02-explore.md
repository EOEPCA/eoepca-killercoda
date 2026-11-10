Check the deployed services:

```
kubectl get pods -n workspace
kubectl get pods -n data-access
```{{exec}}

Check the IAM realm and STAC API:

```
curl --fail --silent --show-error http://auth.eoepca.local/realms/eoepca/.well-known/openid-configuration | jq '.issuer'
curl --fail --silent --show-error http://eoapi.eoepca.local/stac/ | jq
```{{exec}}

Open the [Workspace UI]({{TRAFFIC_HOST1_81}}/workspaces), [STAC Browser]({{TRAFFIC_HOST1_82}}/browser/) or [STAC Manager]({{TRAFFIC_HOST1_82}}/manager/).

The workshop accounts are `eoepcauser` and `eoepcaadmin`, both with password `eoepcapassword`. The administrator can create workspaces and register public collections. A regular user can register private collections prefixed with `eoepcauser.`.

Activate the notebook environment:

```
source ~/datacube-venv/bin/activate
```{{exec}}

and check that the required Python libraries are available:

```
python -c 'import pystac, odc.stac, xarray, boto3; print("Notebook libraries available")'
```{{exec}}

