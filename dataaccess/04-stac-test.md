```
cd collections/sentinel-2-iceland
curl -s -X POST http://eoapi.eoepca.local/stac/collections \
  -H "Content-Type: application/json" \
  -d @collections.json \
  | jq
```{{exec}}

```
i=0
jq -c '.[]' items.json | while read -r item; do
  i=$((i+1))
  echo "$item" | curl -s -o /dev/null -w "$i %{http_code} %{url_effective}\n" \
    -X POST http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items \
    -H "Content-Type: application/json" \
    -d @-
done
```{{exec}}
