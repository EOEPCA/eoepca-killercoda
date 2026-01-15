
EODAG can run as a STAC-compliant REST API server, exposing configured providers through a standard STAC interface.

> **Note**: The `serve-rest` command is deprecated since EODAG v3.9.0 and will be removed in a future version. For production use, see [stac-fastapi-eodag](https://github.com/CS-SI/stac-fastapi-eodag). However, it remains functional for learning and testing purposes.

### Start the STAC Server

Start EODAG as a STAC server in the background:

```

eodag serve-rest --world --port 5000 2>&1 & sleep 3

```{{exec}}

The options mean:
- `--world`: Bind to all network interfaces (0.0.0.0)
- `--port`: Port to listen on

### Access the STAC API

Query the root endpoint:

```

curl -s http://localhost:5000 | jq . | head -30

```{{exec}}

### List Collections

Get all available collections (product types):

```

curl -s "http://localhost:5000/collections" | jq . | head -50

```{{exec}}

Filter collections by provider:

```

curl -s "http://localhost:5000/collections?provider=earth_search" | jq . | head -50

```{{exec}}

### Search via STAC API

Search for SENTINEL2 products using the STAC search endpoint:

```

curl -s "http://localhost:5000/search?collections=S2_MSI_L1C&bbox=1,43,2,44&datetime=2024-01-01/2024-01-15&limit=5" | jq .

```{{exec}}


### Integration with STAC Browser

The EODAG STAC server is compatible with standard STAC clients like the [Radiant Earth STAC Browser](https://radiantearth.github.io/stac-browser/). In a production environment, you could point the STAC Browser to your EODAG server URL.

### Stop the Server

```

pkill -f "eodag serve-rest"
```{{exec}}