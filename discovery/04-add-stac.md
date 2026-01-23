So, now we have our Resource Discovery catalogue, we need to fill it with products.

To do so, we can use the catalogue STAC APIs, for which you will see details in the [Swagger documentation]({{TRAFFIC_HOST1_81}}/openapi?f=html) in the same instance you just installed.

### Add a collection

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

We can now register it via

```
curl -X POST 'http://resource-catalogue.eoepca.local/stac/collections/metadata:main/items' \
  --silent \
  -H "Content-Type: application/json" \
  -d @CAT_DEMO.json | jq
```{{exec}}

You should be now able to see the CAT_DEMO collection via the STAC API

```
curl --silent http://resource-catalogue.eoepca.local/stac/collections | jq .collections[].id
```{{exec}}

or via the [STAC browser](https://radiantearth.github.io/stac-browser/#/external/{{TRAFFIC_HOST1_81}}/stac) or via the [internal GUI]({{TRAFFIC_HOST1_81}}/collections/metadata:main/items)

> NOTE that the STAC Browser will not work in the case that (insecure) `http` has been used to expose the Resource Catalogue service, though it may work in some browsers (like Firefox) if you allow mixed http/https content for the site in your browser

### Add an Item

Let's add then a STAC Item to the created collection. To do so, we need the STAC of this product

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
curl -X POST 'http://resource-catalogue.eoepca.local/stac/collections/CAT_DEMO/items' \
  --silent \
  -H "Content-Type: application/json" \
  -d @example-item.json | jq
```{{exec}}

we can now see the sample product we have ingested via the STAC API

```
curl --silent http://resource-catalogue.eoepca.local/stac/collections/CAT_DEMO/items | jq .features[].id
```{{exec}}

And in the [STAC browser](https://radiantearth.github.io/stac-browser/#/external/{{TRAFFIC_HOST1_81}}/stac) or via the [internal GUI]({{TRAFFIC_HOST1_81}}/collections/CAT_DEMO/items)

> NOTE that the STAC Browser will not work in the case that (insecure) `http` has been used to expose the Resource Catalogue service, though it may work in some browsers (like Firefox) if you allow mixed http/https content for the site in your browser
