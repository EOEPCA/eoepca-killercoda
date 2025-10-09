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

We can do some search on the catalogue.

First, we build a query in JSON format, where we define the collection, the coordinates, the time interval and cloud cover. This example is an exact equivalent of what is used in the sample [EOEPCA Jupyter Notebook](https://github.com/EOEPCA/demo/blob/main/demoroot/notebooks/04%20Data%20Access.ipynb)
```
cat <<EOF > search-body.json
{
  "filter-lang": "cql2-json",
  "limit": 20,
  "sortby": [
    {
      "direction": "desc",
      "field": "properties.datetime"
    }
  ],
  "context": "on",
  "filter": {
    "op": "and",
    "args": [
      {
        "op": "=",
        "args": [
          { "property": "collection" },
          "sentinel-2-iceland"
        ]
      },
      {
        "op": "s_intersects",
        "args": [
          { "property": "geometry" },
          {
            "type": "Polygon",
            "coordinates": [
              [
                [-21.470015412404706, 63.55594801099713],
                [-20.336567910645556, 63.55594801099713],
                [-20.336567910645556, 64.17209253282897],
                [-21.470015412404706, 64.17209253282897],
                [-21.470015412404706, 63.55594801099713]
              ]
            ]
          }
        ]
      },
      {
        "op": "t_intersects",
        "args": [
          { "property": "datetime" },
          { "interval": ["2023-01-01T00:00:00Z", "2023-12-31T23:59:59Z"] }
        ]
      },
      {
        "op": "<=",
        "args": [
          { "property": "eo:cloud_cover" },
          100
        ]
      }
    ]
  }
}
EOF
```{{exec}}

Then we run the query. We only display the IDs of the found STAC items because the entire JSON data is too long, but we save it in whole to a file `stac-items.json` for later use:
```
curl -s -X POST "http://eoapi.eoepca.local/stac/search" \
  -H "Content-Type: application/json" \
  -d @search-body.json \
  | tee stac-items.json \
  | jq ".features.[].id"
```{{exec}}
