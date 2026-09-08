The CLI is convenient for a person at a terminal, but applications often need an HTTP interface. EODAG can expose its providers through a STAC API, allowing standard STAC clients to search the same gateway.

> **Note**: This used to be part of eodag and is now stac-fastapi-eodag

### Start the STAC Server

Install the server and start it in the background:

```
pip install "stac-fastapi.eodag[server]==0.4.0"
python -m stac_fastapi.eodag.app > /tmp/eodag-stac.log 2>&1 &
EODAG_SERVER_PID=$!
```{{exec}}

The server loads every provider definition before it accepts requests, which takes a few seconds. Wait for it:

```
timeout 60 bash -c 'until curl -fs http://localhost:8000/ >/dev/null; do sleep 2; done'
echo "EODAG STAC API ready"
```{{exec}}

Redirecting the server log keeps it separate from our client commands. If startup fails, inspect it with `cat /tmp/eodag-stac.log`.

### Inspect the STAC Landing Page

The root resource identifies the catalogue and advertises links to related API resources:

```
curl -fsS http://localhost:8000/ |
  jq '{type, id, title, description, link_relations: [.links[].rel]}'
```{{exec}}

### List Collections

EODAG exposes its collections through the STAC API. The response is paged, so read the total from `numberMatched`:

```
curl -fsS "http://localhost:8000/collections" | jq '{numberMatched, numberReturned}'
curl -fsS "http://localhost:8000/collections" | jq '.collections[0:5] | map({id, title})'
```{{exec}}

The collection IDs are EODAG's common collection IDs. This is why `S2_MSI_L1C` can be used consistently by the CLI, STAC API, and Python API.

### Search via STAC API

Use the STAC Item Search endpoint with the same collection, bounding box, time interval, and five-item limit used earlier. `datetime` takes an RFC 3339 interval. The server picks a provider itself, the same way the CLI and Python API do; the answering provider is recorded per item under `federation:backends`:

```
curl -fsS "http://localhost:8000/search?collections=S2_MSI_L1C&bbox=1,43,2,44&datetime=2024-01-01T00:00:00Z/2024-01-15T00:00:00Z&limit=5" |
  jq '.features | map({id, datetime: .properties.datetime, cloud_cover: .properties."eo:cloud_cover", provider: .properties."federation:backends"})'
```{{exec}}

The response is a STAC `FeatureCollection`. Each feature is a STAC Item, and its `assets` object describes the files associated with that product.

### Select a Provider over HTTP

`federation:backends` is also a searchable property. The STAC `query` extension uses it to pin a request to one backend, which is the HTTP equivalent of `eodag search -p earth_search`:

```
curl -fsS -G "http://localhost:8000/search" \
  --data-urlencode "collections=S2_MSI_L1C" \
  --data-urlencode "bbox=1,43,2,44" \
  --data-urlencode "datetime=2024-01-01T00:00:00Z/2024-01-15T00:00:00Z" \
  --data-urlencode "limit=3" \
  --data-urlencode 'query={"federation:backends":{"eq":"earth_search"}}' |
  jq '.features | map({id, provider: .properties."federation:backends"})'
```{{exec}}

Every item now comes from `earth_search`.

### Browse the API

The server publishes interactive API documentation, from which the same searches can be run in a browser:

[Open the EODAG STAC API]({{TRAFFIC_HOST1_81}}/api.html)

Expand `GET /search`, select **Try it out**, and repeat the query above with `collections` set to `S2_MSI_L1C`.

The API root itself is at [{{TRAFFIC_HOST1_81}}]({{TRAFFIC_HOST1_81}}). The `href` values in its responses are the server's own `localhost:8000` addresses, so STAC clients such as [STAC Browser](https://radiantearth.github.io/stac-browser/) or PySTAC Client need to run alongside the server rather than against this tutorial URL. In production, `stac-fastapi-eodag` would be deployed behind a stable ingress URL and clients would use that as their catalogue root.

### Stop the Server

Stop only the background process started in this step:

```
kill "$EODAG_SERVER_PID"
wait "$EODAG_SERVER_PID" 2>/dev/null || true
echo "EODAG STAC API stopped"
```{{exec}}
