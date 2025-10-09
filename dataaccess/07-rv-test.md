see how to demo the raster... maybe the best is to do some curl to the WMTS and then use an external WMTS client, look for the web if we find one...

### OGC API

We will now rendedr raster tiles from a single STAC item in the STAC collection that we found through our search the STAC catalogue in the previous step.

FIrst, we extract the ID of the STAC item and fetch the TileJSON for it (a parametrized URL that will be used for generating raster tiles):
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

From the obtained TileJSON file we extract the relevant values and use them to populate a prepared HTML map template:
```
PORT=$(cat /tmp/assets/killercodaproxy | head -n1 | cut -f1 -d' ')
EOAPI_HOST=$(sed -e "s|PORT|${PORT}|" /etc/killercoda/host)

export TILES_URL=$(jq -r '.tiles[0]' tilejson.json | sed -e "s|http://eoapi.eoepca.local|${EOAPI_HOST}|")
export CENTER_LAT=$(jq -r '.center[1]' tilejson.json)
export CENTER_LON=$(jq -r '.center[0]' tilejson.json)
export MIN_ZOOM=$(jq -r '.minzoom' tilejson.json)
export MAX_ZOOM=$(jq -r '.maxzoom' tilejson.json)

envsubst < /tmp/assets/map-template.html > /var/www/html/map-item.html
```{{exec}}

Now we can see see [our tile on the map]({{TRAFFIC_HOST1_99}}/map-item.html).

### WMTS

We can do a similar thing for the entire collection. This time we will use the WMTS capability of the raster OGC API and `gdal`.

First we get WMTS service description from the WMTSCapabilities endpoint. This requires specifying at least the `assets` parameter, we additionally add `color_formula` - different than previously:
```
gdal_translate "WMTS:http://eoapi.eoepca.local/raster/collections/sentinel-2-iceland/WebMercatorQuad/WMTSCapabilities.xml?assets=visual&color_formula=Gamma+RGB+3.5+Saturation+1.7+Sigmoidal+RGB+15+0.35,layer=default" wmts.xml -of WMTS
```{{exec}}

We check the sanity and correctness of the generated WMTS descrption file: 
```
gdalinfo wmts.xml
```{{exec}}

Finally, we use the WMTS descrpition file and `gdal2tiles.py` to generate tiles for the collection. We set zoom levels 7-9, the web viewer to _leaflet_  and output the results to a folder where the HTTP server can see them.
```
export GDAL_ENABLE_WMS_CACHE=NO
gdal2tiles.py -z "7-9" -r bilinear -w leaflet wmts.xml /var/www/html/sentinel-2-iceland
```{{exec}}

Now we can view [our collection tiles on the map]({{TRAFFIC_HOST1_99}}/sentinel-2-iceland/leaflet.html).
