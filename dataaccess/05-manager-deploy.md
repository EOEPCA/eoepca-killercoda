```
curl -s http://eoapi.eoepca.local/stac/collections | jq ".collections.[].id"
```{{exec}}

```
curl -s http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland | jq
```{{exec}}

```
curl -s http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items | jq
```{{exec}}

```
curl -s http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items | jq ".features.[].id"
```{{exec}}

```
curl -X POST "http://eoapi.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d '{
    "bbox": [-25, 63, -24, 65],
    "datetime": "2023-01-01T00:00:00Z/2024-01-01T00:00:00Z",
    "limit": 5
  }' | jq ".features.[].{id | .datetime}"
```{{exec}}
