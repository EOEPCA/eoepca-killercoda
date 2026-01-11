
EODAG can run as a STAC-compliant REST API server, exposing configured providers through a standard STAC interface.

### Start the STAC Server

Start EODAG as a STAC server in the background:

```
eodag serve-rest --world --port 5000 &
sleep 3
```{{exec}}

The options mean:
- `--world`: Bind to all network interfaces (0.0.0.0)
- `--port`: Port to listen on

### Access the STAC API

Query the root endpoint:

```
curl -s http://localhost:5000 | python3 -m json.tool | head -30
```{{exec}}

### List Collections

Get all available collections (product types):

```
curl -s "http://localhost:5000/collections" | python3 -m json.tool | head -50
```{{exec}}

Filter collections by provider:

```
curl -s "http://localhost:5000/collections?provider=earth_search" | python3 -m json.tool | head -50
```{{exec}}

### Search via STAC API

Search for Sentinel-2 products using the STAC search endpoint:

```
curl -s "http://localhost:5000/search?collections=S2_MSI_L1C&bbox=1,43,2,44&datetime=2024-01-01/2024-01-15&limit=5" | python3 -m json.tool
```{{exec}}

### POST Search Request

You can also use POST requests with a JSON body:

```
curl -s -X POST "http://localhost:5000/search" \
  -H "Content-Type: application/json" \
  -d '{
    "collections": ["S2_MSI_L1C"],
    "bbox": [1, 43, 2, 44],
    "datetime": "2024-01-01/2024-01-10",
    "limit": 3
  }' | python3 -m json.tool
```{{exec}}


### Integration with STAC Browser

The EODAG STAC server is compatible with standard STAC clients like the [Radiant Earth STAC Browser](https://radiantearth.github.io/stac-browser/). In a production environment, you could point the STAC Browser to your EODAG server URL.

### Stop the Server

```
pkill -f "eodag serve-rest"
```{{exec}}