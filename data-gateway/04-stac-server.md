The CLI is convenient for a person at a terminal, but applications often need an HTTP interface. EODAG can expose its providers through a STAC API, allowing standard STAC clients to search the same gateway.

> **Note**: The `serve-rest` command is deprecated since EODAG v3.9.0 and will be removed in a future version. For production use, see [stac-fastapi-eodag](https://github.com/CS-SI/stac-fastapi-eodag). However, it remains functional for learning and testing purposes.

### Start the STAC Server

Start the server in the background, save its process ID, and perform a bounded readiness check. Initialisation can take more than three seconds while EODAG loads its provider definitions.

```
eodag serve-rest --world --port 5000 > /tmp/eodag-stac.log 2>&1 &
export EODAG_SERVER_PID=$!

for attempt in $(seq 1 20); do
  if curl -fsS http://localhost:5000/ > /dev/null 2>&1; then
    echo "EODAG STAC API is ready"
    break
  fi
  sleep 1
done

curl -fsS http://localhost:5000/ > /dev/null ||
  { echo "Server did not become ready; inspect /tmp/eodag-stac.log"; false; }
```{{exec}}

The options mean:

- `--world`: Bind to all network interfaces (0.0.0.0)
- `--port`: Port to listen on

Redirecting the server log keeps it separate from our client commands. If startup fails, inspect it with `cat /tmp/eodag-stac.log`.

### Inspect the STAC Landing Page

The root resource identifies the catalogue and advertises links to related API resources:

```
curl -fsS http://localhost:5000/ |
  jq '{type, id, title, description, link_relations: [.links[].rel]}'
```{{exec}}

### List Collections

EODAG exposes product types as STAC collections. Asking for every provider produces a large response, so select the public Earth Search provider:

```
curl -fsS "http://localhost:5000/collections?provider=earth_search" |
  jq '{
    returned: (.collections | length),
    collections: [.collections[] | {id, title}]
  }'
```{{exec}}

The collection IDs are EODAG's common product-type IDs. This is why `S2_MSI_L1C` can be used consistently by the CLI, STAC API, and Python API.

### Search via STAC API

Use the STAC Item Search endpoint with the same collection, bounding box, time interval, and five-item limit used earlier. Here the EODAG server supports a `provider` query parameter, so the request explicitly targets Earth Search:

```
curl -fsS \
  "http://localhost:5000/search?provider=earth_search&collections=S2_MSI_L1C&bbox=1,43,2,44&datetime=2024-01-01/2024-01-15&limit=5" |
  jq '{
    type,
    returned: .numberReturned,
    products: [.features[] | {
      id,
      datetime: .properties.datetime,
      cloud_cover: .properties["eo:cloud_cover"]
    }]
  }'
```{{exec}}

The response is a STAC `FeatureCollection`. Each feature is a STAC Item, and its `assets` object describes the files associated with that product.

### Integration with STAC Browser

The API can also be consumed by tools such as [STAC Browser](https://radiantearth.github.io/stac-browser/) or Python clients such as PySTAC Client. In production, `stac-fastapi-eodag` would be deployed behind a stable ingress URL and a client would use that URL as its catalogue root.

### Stop the Server

Stop only the background process started in this step:

```
kill "$EODAG_SERVER_PID"
wait "$EODAG_SERVER_PID" 2>/dev/null || true
echo "EODAG STAC API stopped"
```{{exec}}
