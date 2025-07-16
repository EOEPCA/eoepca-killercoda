We now have a STAC catalogue, which we can access at

```
curl -sS http://eoapi.eoepca.local/stac | jq
```{{exec}}

We can fill it with a sample STAC collection

```
curl -s -X POST http://eoapi.eoepca.local/stac/collections \
  -H "Content-Type: application/json" \
  -d @collections/sentinel-2-iceland/collections.json \
  | jq
```{{exec}}

And some sample items (we restrict ourself to the first 20 demo items)

```
i=0
jq -c '.[]' collections/sentinel-2-iceland/items.json 2>/dev/null | while read -r item; do
  i=$((i+1))
  echo "$item" | curl -s -o /dev/null -w "$i %{http_code} %{url_effective}\n" \
    -X POST http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items \
    -H "Content-Type: application/json" \
    -d @-
  [[ $i -gt 19 ]] && break
done
```{{exec}}

Now, we should be able to see our collection and items via a STAC query

```
curl -sS http://eoapi.eoepca.local/stac/collections/sentinel-2-iceland/items | jq -r .features[].id
```{{exec}}

or directly via the [STAC browser](https://radiantearth.github.io/stac-browser/#/external/{{TRAFFIC_HOST1_81}}/stac/collections/sentinel-2-iceland) (by connecting to the catalogue external interface)

