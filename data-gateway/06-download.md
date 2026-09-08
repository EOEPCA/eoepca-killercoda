Discovery is only half of the gateway. The product objects returned by a search also carry everything EODAG needs to fetch the data, so an application can go from matching scenes to local files without implementing each provider's download protocol.

### Choose a Provider

Copernicus Data Space and Earth Search both need an account before their data can be retrieved, and this workshop uses no credentials. Microsoft Planetary Computer serves Sentinel-2 anonymously, so we use it here. On Planetary Computer the Level-2A collection is `S2_MSI_L2A`.

Start Python again:

```
source ~/venv/bin/activate
python3
```{{exec}}

### Find a Low-Cloud Scene

```python
from eodag import EODataAccessGateway
dag = EODataAccessGateway()

results = dag.search(
    collection="S2_MSI_L2A",
    geom={"lonmin": 1, "latmin": 43, "lonmax": 2, "latmax": 44},
    start="2024-06-01",
    end="2024-06-30",
    provider="planetary_computer",
    limit=1,
    **{"eo:cloud_cover": 20}
)
product = results[0]
print(product.properties.get("id"))
print(product.properties.get("eo:cloud_cover"))
```{{exec}}

### List the Available Assets

```python
assets = product.as_dict()["assets"]
print(list(assets))
```{{exec}}

The band assets (`B02`, `B03`, `B04`, ...) are the full-resolution images and are hundreds of megabytes each. `PVI` is the preview image produced with the product: a small georeferenced true-colour raster of the whole tile.

### Download One Asset

`asset` takes a regular expression matched against those names, so the download is restricted to `PVI`. `output_dir` must be an absolute path:

```python
path = dag.download(product, asset="PVI", output_dir="/root/eodata")
print(path)
```{{exec}}

A progress bar shows the transfer. EODAG obtains and applies the Planetary Computer access token itself; nothing about that provider's signing scheme appears in this code.

### See the Scene

Print the link to the provider's rendered preview of the same acquisition, then leave Python:

```python
print(assets["preview.png"]["href"])
exit()
```{{exec}}

Open that URL in a browser to see the tile we just retrieved.

### Inspect What Was Downloaded

```
find ~/eodata -type f -exec ls -lh {} \;
```{{exec}}

One GeoTIFF of a few hundred kilobytes, named after the product and the tile. The gateway searched a federated catalogue, queried the chosen backend, resolved the asset URL, obtained provider access and wrote the data to local storage, all through the same API used for the searches in the earlier steps.

To retrieve the complete product instead, drop the `asset` argument, or use `dag.download_all(results, output_dir="/root/eodata")` for every result in a search.
