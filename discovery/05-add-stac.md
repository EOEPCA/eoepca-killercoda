The catalogue is empty, so we now register some Earth Observation metadata. Writes go to the protected endpoint and need an access token; reads are served by the open endpoint without one.

The metadata used here describes two real Sentinel-2 Level-2A scenes, one over central Italy and one over southern Greece. Their footprints are simplified to the scene bounding box to keep the examples short.

### Get an access token

The `resource-catalogue` Keycloak client has the OAuth2 device authorization grant enabled, which is the simplest way to get a token in a terminal.

```
source ~/.eoepca/state

VERIFIER=$(openssl rand -hex 32)
CHALLENGE=$(printf '%s' "$VERIFIER" | openssl dgst -sha256 -binary | openssl base64 -A | tr '+/' '-_' | tr -d '=')

DEVICE=$(curl -sS -X POST "${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/auth/device" \
  --data-urlencode "client_id=resource-catalogue" \
  --data-urlencode "code_challenge=${CHALLENGE}" \
  --data-urlencode "code_challenge_method=S256")

echo "$DEVICE" | jq -r '"Open \(.verification_uri_complete) and log in as eoepcauser"'
```{{exec}}

Open the printed URL and log in as `eoepcauser`{{}} / `eoepcapassword`{{}}, a user which the deployment scripts added to the `resource-catalogue-admin` group. The first time this client is used, Keycloak also asks you to grant it access - click **Yes**. Now exchange the device code for a token:

```
DEVICE_CODE=$(echo "$DEVICE" | jq -r '.device_code')

ACCESS_TOKEN=$(curl -sS -X POST "${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/token" \
  --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
  --data-urlencode "device_code=${DEVICE_CODE}" \
  --data-urlencode "client_id=resource-catalogue" \
  --data-urlencode "code_verifier=${VERIFIER}" | jq -r '.access_token')
```{{exec}}

> The token is valid for five minutes. If a request on this page returns `401`{{}}, run the two commands above again to get a new one.

### Create a collection

STAC items live in collections. A collection is registered as a record of the catalogue's own `metadata:main` collection:

```
cat > sentinel-2-demo.json <<'EOF'
{
  "type": "Collection",
  "stac_version": "1.0.0",
  "id": "sentinel-2-demo",
  "title": "Sentinel-2 L2A demo scenes",
  "description": "Sample Sentinel-2 Level-2A scenes registered during this tutorial",
  "license": "proprietary",
  "links": [],
  "extent": {
    "spatial": { "bbox": [[11.35, 36.90, 24.53, 42.43]] },
    "temporal": { "interval": [["2024-06-01T00:00:00Z", "2024-10-01T00:00:00Z"]] }
  }
}
EOF

curl -s -o /dev/null -w "%{http_code}\n" \
  -X POST "http://resource-catalogue-protected.eoepca.local/stac/collections/metadata:main/items" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @sentinel-2-demo.json
```{{exec}}

`201`{{}} means the collection was created. It is immediately visible through the open endpoint:

```
curl -s http://resource-catalogue.eoepca.local/stac/collections | jq '.collections[].id'
```{{exec}}

### Register two scenes

```
cat > rome.json <<'EOF'
{
  "type": "Feature",
  "stac_version": "1.0.0",
  "id": "S2B_33TTG_20240628_0_L2A",
  "collection": "sentinel-2-demo",
  "bbox": [11.35, 41.41, 12.72, 42.43],
  "geometry": {
    "type": "Polygon",
    "coordinates": [[[11.35, 41.41], [12.72, 41.41], [12.72, 42.43], [11.35, 42.43], [11.35, 41.41]]]
  },
  "properties": {
    "title": "Sentinel-2B L2A, tile 33TTG (Rome)",
    "datetime": "2024-06-28T10:09:15Z",
    "platform": "sentinel-2b",
    "eo:cloud_cover": 0.001
  },
  "assets": {
    "thumbnail": {
      "href": "https://sentinel-cogs.s3.us-west-2.amazonaws.com/sentinel-s2-l2a-cogs/33/T/TG/2024/6/S2B_33TTG_20240628_0_L2A/thumbnail.jpg",
      "type": "image/jpeg",
      "roles": ["thumbnail"]
    }
  },
  "links": []
}
EOF

cat > athens.json <<'EOF'
{
  "type": "Feature",
  "stac_version": "1.0.0",
  "id": "S2A_34SGG_20240926_0_L2A",
  "collection": "sentinel-2-demo",
  "bbox": [23.25, 36.91, 24.53, 37.93],
  "geometry": {
    "type": "Polygon",
    "coordinates": [[[23.25, 36.91], [24.53, 36.91], [24.53, 37.93], [23.25, 37.93], [23.25, 36.91]]]
  },
  "properties": {
    "title": "Sentinel-2A L2A, tile 34SGG (Athens)",
    "datetime": "2024-09-26T09:20:07Z",
    "platform": "sentinel-2a",
    "eo:cloud_cover": 0.004
  },
  "assets": {
    "thumbnail": {
      "href": "https://sentinel-cogs.s3.us-west-2.amazonaws.com/sentinel-s2-l2a-cogs/34/S/GG/2024/9/S2A_34SGG_20240926_0_L2A/thumbnail.jpg",
      "type": "image/jpeg",
      "roles": ["thumbnail"]
    }
  },
  "links": []
}
EOF
```{{exec}}

Post both items to the collection:

```
for scene in rome athens; do
  curl -s -o /dev/null -w "$scene: %{http_code}\n" \
    -X POST "http://resource-catalogue-protected.eoepca.local/stac/collections/sentinel-2-demo/items" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @$scene.json
done
```{{exec}}

Both scenes are now in the catalogue:

```
curl -s http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-demo/items | jq '.features[].id'
```{{exec}}

### Remove and re-register a scene

The transactional endpoint also supports `DELETE`{{}}. Remove the Athens scene:

```
curl -s -o /dev/null -w "%{http_code}\n" \
  -X DELETE "http://resource-catalogue-protected.eoepca.local/stac/collections/sentinel-2-demo/items/S2A_34SGG_20240926_0_L2A" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}"

curl -s http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-demo/items | jq '.features[].id'
```{{exec}}

Only the Rome scene is left. Register the Athens scene again, because we search for it in the next step:

```
curl -s -o /dev/null -w "%{http_code}\n" \
  -X POST "http://resource-catalogue-protected.eoepca.local/stac/collections/sentinel-2-demo/items" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @athens.json
```{{exec}}

### Correct the metadata of a scene

Metadata often changes after a product is reprocessed. `PUT`{{}} replaces the whole record. Here we raise the reported cloud cover of the Athens scene:

```
sed 's/"eo:cloud_cover": 0.004/"eo:cloud_cover": 12.5/' athens.json > athens-revised.json

curl -s -o /dev/null -w "%{http_code}\n" \
  -X PUT "http://resource-catalogue-protected.eoepca.local/stac/collections/sentinel-2-demo/items/S2A_34SGG_20240926_0_L2A" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @athens-revised.json
```{{exec}}

`204`{{}} means the record was replaced. Read it back from the open endpoint and check `eo:cloud_cover`:

```
curl -s http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-demo/items/S2A_34SGG_20240926_0_L2A | jq '.properties'
```{{exec}}

Without a token the same write is refused - APISIX redirects to Keycloak rather than passing the request to the catalogue:

```
curl -s -o /dev/null -w "%{http_code}\n" \
  -X POST "http://resource-catalogue-protected.eoepca.local/stac/collections/sentinel-2-demo/items" \
  -H "Content-Type: application/json" \
  -d @athens.json
```{{exec}}
