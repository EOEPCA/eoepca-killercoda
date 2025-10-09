Via the [STAC browser](https://radiantearth.github.io/stac-browser/#/external/{{TRAFFIC_HOST1_81}}/stac/collections/sentinel-2-iceland) you will be able to directly see a visualization of the image, this is because the data samples we are using have data on COG (optimized GeoTIFF) and thus can be simply queried and visualized by the STAC Browser, but if this is not the case, or if you do not want to just visualize the data but do some basic analytics or operations on it, we need an engine that EOEPCA Data Access BB provides.

In this step we will use the [TiTiler-PgSTAC](https://github.com/stac-utils/titiler-pgstac) Raster component of Data Access BB to render raster tiles from our sample collection and visualize the rendered tiles on the map. We will use two methods of access to the data: the OGC API Features and the older standard WMTS which the raster component also supports. We will also show how the rendered tiles can be pre-processed in a basic way by setting a certain color formula. 

## OGC API Features

We will now render raster tiles from a single STAC item in the STAC collection that we found through our search the STAC catalogue in the previous step.

FIrst, we extract the ID of the STAC item and fetch the TileJSON for it (a parametrized URL that will be used for generating raster tiles). 
- We choose the `WebMercatorQuad` tileset, which is not a URL parameter, but a part of the URL path. Full list of available tilesets is available via [the API](https://{{TRAFFIC_HOST1_81}}/raster/tileMatrixSets).
- The `assets` parameter is mandatory, at least one asset must be specified.
- We also use the `color_formula` parameters with the [rio-color syntax](https://github.com/mapbox/rio-color) to perform some basic color-oriented image operations on the rendered tiles.
```
ITEM_ID=$(jq -r '.features[0].id' stac-items.json)
echo "${ITEM_ID}"

curl -sG "http://eoapi.eoepca.local/raster/collections/sentinel-2-iceland/items/${ITEM_ID}/WebMercatorQuad/tilejson.json" \
  --data-urlencode "minzoom=9" \
  --data-urlencode "maxzoom=12" \
  --data-urlencode "assets=red" \
  --data-urlencode "assets=green" \
  --data-urlencode "assets=blue" \
  --data-urlencode "color_formula=Gamma RGB 5 Saturation 0.8 Sigmoidal RGB 20 0.35" \
  --data-urlencode "nodata=0" \
  -H "Accept: application/json" \
  | tee tilejson.json \
  | jq
```{{exec}}

From the obtained TileJSON file we extract the relevant values and use them to populate a prepared HTML map template. To make it visible in the web browser we replace our local domain `eoapi.eoepca.local` with a domain exposed via a proxy:
```
export TILES_URL=$(jq -r '.tiles[0]' tilejson.json | sed -e "s|http://eoapi.eoepca.local|{{TRAFFIC_HOST1_81}}|")
export CENTER_LAT=$(jq -r '.center[1]' tilejson.json)
export CENTER_LON=$(jq -r '.center[0]' tilejson.json)
export MIN_ZOOM=$(jq -r '.minzoom' tilejson.json)
export MAX_ZOOM=$(jq -r '.maxzoom' tilejson.json)

echo ${TILES_URL}

envsubst < /tmp/assets/map-template.html > /var/www/html/map-item.html
```{{exec}}

Now we can see see our tiles for the selected item [on the map]({{TRAFFIC_HOST1_99}}/map-item.html). In this case our tiles are rendered on-the-fly when the JavaScript library `leaflet` used to render the map in the browser fetches them from the given URL.


## WMTS

We can do a similar thing for the entire collection. This time we will use the WMTS capability of the TiTiler raster component and Geospatial Data Abstraction Library tools [GDAL](https://gdal.org/) for rendering the tiles. In this case the tiles will be pre-rendered as PNG images.

First we get WMTS service description from the WMTSCapabilities endpoint. This requires specifying at least the `assets` parameter. We additionally add `color_formula` to pre-process the tiles (we choose it different than previously):
```
gdal_translate -of WMTS "WMTS:http://eoapi.eoepca.local/raster/collections/sentinel-2-iceland/WebMercatorQuad/WMTSCapabilities.xml?assets=visual&color_formula=Gamma+RGB+1.2+Saturation+1.2+Sigmoidal+RGB+10+0.35,layer=default" wmts.xml
```{{exec}}

We check the sanity and correctness of the generated WMTS descrption file: 
```
gdalinfo wmts.xml
```{{exec}}

Finally, we use the WMTS descrpition file and `gdal2tiles.py` to generate tiles for the collection. We set zoom levels to 7-9, the web viewer to `leaflet` and output the results to a folder where our local HTTP server can see them.
```
export GDAL_ENABLE_WMS_CACHE=NO
gdal2tiles.py -z "7-9" -r bilinear -w leaflet wmts.xml /var/www/html/sentinel-2-iceland
```{{exec}}

Once the tiles for the collection are rendered for all zoom levels, we can view them [on the map]({{TRAFFIC_HOST1_99}}/sentinel-2-iceland/leaflet.html).
