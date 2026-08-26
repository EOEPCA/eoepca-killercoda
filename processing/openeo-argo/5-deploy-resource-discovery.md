## Deploy Resource Discovery and Register Sample Data

OpenEO needs a STAC API to discover input data from. We deploy the EOEPCA Resource Discovery Building Block for this.

### Configure and deploy

```bash
cd ~/deployment-guide/scripts/resource-discovery
bash check-prerequisites.sh
```{{exec}}

This reuses the shared configuration already collected in the earlier prerequisites step, so it should complete with no further prompts.

Configure Resource Discovery. We need a writable catalogue to register our own sample data, so answer `yes` to enable the IAM-protected transactional endpoint:

```bash
bash configure-resource-discovery.sh <<EOF
yes
EOF
```{{exec}}

Deploy both the read-only catalogue (what OpenEO itself will query) and the IAM-protected writable catalogue (what we'll use to register data):

```bash
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev

helm upgrade -i resource-discovery eoepca-dev/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.1.0-dev2 \
  --namespace resource-discovery \
  --create-namespace
kubectl apply -f generated-ingress.yaml

helm upgrade -i resource-catalogue-protected eoepca-dev/rm-resource-catalogue \
  --values generated-protected-values.yaml \
  --version 2.1.0-dev2 \
  --namespace resource-discovery
kubectl apply -f generated-protected-ingress.yaml

kubectl apply -f generated-iam.yaml
kubectl apply -f generated-db-secret.yaml
```{{exec}}

Wait for the read-only STAC endpoint to come up:

```bash
while [[ $(curl -s -o /dev/null -w "%{http_code}" http://resource-catalogue.eoepca.local/stac) != 200 ]]; do sleep 5; done
curl -fsS http://resource-catalogue.eoepca.local/stac | jq '{title, description}'
```{{exec}}

### Prepare a sample Sentinel-2 dataset

We need some real data for OpenEO to process. Run the asset script, which crops a couple of small Sentinel-2 bands and uploads them to the MinIO instance in the cluster:

```bash
bash /tmp/assets/prepare-sample-data
```{{exec}}

This runs entirely inside the cluster and is safe to re-run.

### Register the collection and item

Get a token for the writable catalogue using the [Device Authorization Grant](https://oauth.net/2/device-flow/):

```bash
source ~/.eoepca/state

DEVICE=$(curl -s -X POST "${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/auth/device" \
  -d "client_id=resource-catalogue")

echo "$DEVICE" | jq -r '"Open \(.verification_uri_complete) and log in as eoepcauser"'
```{{exec}}

Open the printed URL and log in with username `eoepcauser`{{copy}} and password `eoepcapassword`{{copy}}. Keycloak will then ask you to grant access to `resource-catalogue` - click **Yes**. Once done, exchange the device code for a token:

```bash
DEVICE_CODE=$(echo "$DEVICE" | jq -r '.device_code')

ACCESS_TOKEN=$(curl -s -X POST "${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/token" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
  -d "device_code=${DEVICE_CODE}" \
  -d "client_id=resource-catalogue" | jq -r '.access_token')
```{{exec}}

Register the collection:

```bash
cat <<'EOF' > CAT_DEMO.json
{
    "stac_version": "1.0.0",
    "type": "Collection",
    "license": "proprietary",
    "id": "sentinel-2-demo",
    "title": "Sentinel-2 demo collection",
    "description": "A small Sentinel-2 L2A crop (bands B04/B08) for the openEO ArgoWorkflows tutorial.",
    "links": [],
    "extent": {
      "spatial": {"bbox": [[4.998, 52.000, 5.052, 52.050]]},
      "temporal": {"interval": [["2026-06-13T00:00:00Z", "2026-06-13T00:00:00Z"]]}
    }
}
EOF

curl -sS -o /dev/null -w 'collection: HTTP %{http_code}\n' \
  -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d @CAT_DEMO.json \
  http://resource-catalogue-protected.eoepca.local/stac/collections/metadata:main/items
```{{exec}}

And the item:

```bash
cat <<'EOF' > demo-item.json
{
    "type": "Feature",
    "stac_version": "1.0.0",
    "stac_extensions": [
      "https://stac-extensions.github.io/projection/v1.1.0/schema.json",
      "https://stac-extensions.github.io/raster/v1.1.0/schema.json",
      "https://stac-extensions.github.io/eo/v1.1.0/schema.json"
    ],
    "id": "S2B_31UFT_20260613_demo-crop",
    "collection": "sentinel-2-demo",
    "properties": {"datetime": "2026-06-13T10:46:19Z", "proj:epsg": 32631},
    "geometry": {
      "type": "Polygon",
      "coordinates": [[[4.998,52.000],[5.052,52.000],[5.052,52.050],[4.998,52.050],[4.998,52.000]]]
    },
    "bbox": [4.998, 52.000, 5.052, 52.050],
    "assets": {
      "red": {
        "href": "http://minio.eoepca.local:9000/eoepca/openeo-samples/B04.tif",
        "type": "image/tiff; application=geotiff; profile=cloud-optimized",
        "eo:bands": [{"name": "B04", "common_name": "red", "center_wavelength": 0.665}],
        "raster:bands": [{"nodata": 0, "data_type": "uint16", "spatial_resolution": 10}]
      },
      "nir": {
        "href": "http://minio.eoepca.local:9000/eoepca/openeo-samples/B08.tif",
        "type": "image/tiff; application=geotiff; profile=cloud-optimized",
        "eo:bands": [{"name": "B08", "common_name": "nir", "center_wavelength": 0.842}],
        "raster:bands": [{"nodata": 0, "data_type": "uint16", "spatial_resolution": 10}]
      }
    },
    "links": []
}
EOF

curl -sS -o /dev/null -w 'item: HTTP %{http_code}\n' \
  -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d @demo-item.json \
  http://resource-catalogue-protected.eoepca.local/stac/collections/sentinel-2-demo/items
```{{exec}}

Both requests should return HTTP `201`. Verify the data is visible through the read-only endpoint:

```bash
curl -fsS http://resource-catalogue.eoepca.local/stac/collections | jq '.collections[].id'

curl -fsS http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-demo/items | jq '.features[].id'
```{{exec}}
