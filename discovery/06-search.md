Discovery is what the catalogue is for. All the searches below use the open endpoint, so no token is needed.

### Search by area

`POST /stac/search`{{}} takes a STAC search request. A bounding box over central Italy matches only the Rome scene:

```
curl -s -X POST "http://resource-catalogue.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{"bbox": [11, 41, 13, 43], "limit": 10}' | jq '.features[].id'
```{{exec}}

### Search by time

The same query without a bounding box, restricted to September 2024, matches only the Athens scene:

```
curl -s -X POST "http://resource-catalogue.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{"datetime": "2024-09-01T00:00:00Z/2024-09-30T23:59:59Z", "limit": 10}' | jq '.features[].id'
```{{exec}}

### Combine both filters

Filters are combined, so asking for September acquisitions over Italy matches nothing:

```
curl -s -X POST "http://resource-catalogue.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{"bbox": [11, 41, 13, 43], "datetime": "2024-09-01T00:00:00Z/2024-09-30T23:59:59Z", "limit": 10}' \
  | jq '{numberMatched, features: [.features[].id]}'
```{{exec}}

`numberMatched`{{}} is `0`{{}}. Moving the box over Greece brings the Athens scene back:

```
curl -s -X POST "http://resource-catalogue.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{"bbox": [23, 36, 25, 38], "datetime": "2024-09-01T00:00:00Z/2024-09-30T23:59:59Z", "limit": 10}' \
  | jq '{numberMatched, features: [.features[].id]}'
```{{exec}}

### Search other catalogues at the same time

The deployment guide configures three external catalogues (`generated-values.yaml`{{}}, under `distributedsearch`{{}}). Adding `distributedSearch=true`{{}} to a STAC search also queries the Copernicus Data Space Ecosystem catalogue and returns its results separately, under `federatedSearchResults`{{}}:

```
curl -s "http://resource-catalogue.eoepca.local/stac/search?distributedSearch=true&limit=2" \
  | jq '.federatedSearchResults.fedcat02.features[].id'
```{{exec}}

These identifiers come from the remote catalogue, not from our database. The same works for the OGC API - Records endpoint, which is federated with the WIS2 discovery catalogue:

```
curl -s "http://resource-catalogue.eoepca.local/collections/metadata:main/items?distributedSearch=true&limit=2" \
  | jq '.federatedSearchResults.fedcat01.features[].id'
```{{exec}}

### Browse the results

The catalogue also serves HTML. Open the [Rome scene]({{TRAFFIC_HOST1_81}}/collections/sentinel-2-demo/items/S2B_33TTG_20240628_0_L2A) to see its metadata, footprint and thumbnail, or the [collection]({{TRAFFIC_HOST1_81}}/collections/sentinel-2-demo/items) to page through both scenes. The [Swagger UI]({{TRAFFIC_HOST1_81}}/openapi?f=html) documents every endpoint of the deployed catalogue.

The catalogue can also be read with the [STAC browser](https://radiantearth.github.io/stac-browser/#/external/{{TRAFFIC_HOST1_81}}/stac).

> NOTE that the STAC Browser will not work in Localcoda because it exposes proxied ports with plain HTTP, though it may work in some browsers (like Firefox) if you allow mixed http/https content for the site in your browser
