So, now we have our Resource Discovery catalogue, we need to fill it with products.

### Add a collection

To add to the catalogue we can use the catalogue STAC Transaction APIs, for which you will see details in the [Swagger documentation]({{TRAFFIC_HOST1_83}}/openapi?f=html) in the same instance you just installed. Use the username `eoepcauser` and password `eoepcapassword`.


First, we can add a Collection for our data. Let's save first the following STAC

```
cat <<EOF | tee CAT_DEMO.json | jq
{
    "stac_version": "1.0.0",
    "type": "Collection",
    "license": "Open Data",
    "id": "CAT_DEMO",
    "title": "Demo collection for killercoda tutorial",
    "description": "This is just a demo collection",
    "links": [],
    "extent": { "spatial": { "bbox": [[-180.0, -90.0, 180.0, 90.0]] } }
}
EOF
```{{exec}}

We will need an access token

```
source ~/.eoepca/state

DEVICE=$(curl -s -X POST "${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/auth/device" \
  -d "client_id=resource-catalogue")

echo "$DEVICE" | jq -r '"Open \(.verification_uri_complete) and log in as stac-admin"'
```{{exec}}

Open the printed URL, log in as a user assigned to the `resource-catalogue-admin` group (`eoepcauser` has been added for you), then exchange the device code for a token:

```bash
DEVICE_CODE=$(echo "$DEVICE" | jq -r '.device_code')

ACCESS_TOKEN=$(curl -s -X POST "${HTTP_SCHEME}://${KEYCLOAK_HOST}/realms/${REALM}/protocol/openid-connect/token" \
  -d "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
  -d "device_code=${DEVICE_CODE}" \
  -d "client_id=resource-catalogue" | jq -r '.access_token')
```{{exec}}

We can now register our STAC collection via

```
curl -X POST 'http://resource-catalogue-protected.eoepca.local/stac/collections/metadata:main/items' \
  --silent \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @CAT_DEMO.json | jq
```{{exec}}

You should be now able to see the CAT_DEMO collection via the STAC API

```
curl --silent http://resource-catalogue.eoepca.local/stac/collections | jq .collections[].id
```{{exec}}

or via the [STAC browser](https://radiantearth.github.io/stac-browser/#/external/{{TRAFFIC_HOST1_81}}/stac) or via the [internal GUI]({{TRAFFIC_HOST1_81}}/collections/metadata:main/items)

> NOTE that the STAC Browser will not work in Localcoda because it exposes proxied ports with plain HTTP, though it may work in some browsers (like Firefox) if you allow mixed http/https content for the site in your browser


### Add an Item

Let's add a STAC Item to the created collection. To do so, we need the STAC for this product

```
cat <<EOF | tee example-item.json | jq
{
    "type": "Feature",
    "stac_version": "1.0.0",
    "id": "example-item",
    "properties": {
      "datetime": "2024-01-01T00:00:00Z"
    },
    "geometry": {
      "type": "Point",
      "coordinates": [0.0, 0.0]
    },
    "bbox": [0.0, 0.0, 0.0, 0.0],
    "assets": {
      "example-data": {
        "href": "https://picsum.photos/200/300",
        "type": "image/jpeg"
      }
    },
    "links": [],
    "collection": "CAT_DEMO"
}
EOF
```{{exec}}

And then we can ingest it, in the CAT_DEMO collection we just created

```
curl -X POST 'http://resource-catalogue-protected.eoepca.local/stac/collections/CAT_DEMO/items' \
  --silent \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @example-item.json | jq
```{{exec}}

we can now see the sample product we have ingested via the STAC API

```
curl --silent http://resource-catalogue.eoepca.local/stac/collections/CAT_DEMO/items | jq .features[].id
```{{exec}}

And in the [STAC browser](https://radiantearth.github.io/stac-browser/#/external/{{TRAFFIC_HOST1_81}}/stac) or via the [internal GUI]({{TRAFFIC_HOST1_81}}/collections/CAT_DEMO/items)

> NOTE that the STAC Browser will not work in Localcoda because it exposes proxied ports with plain HTTP, though it may work in some browsers (like Firefox) if you allow mixed http/https content for the site in your browser
