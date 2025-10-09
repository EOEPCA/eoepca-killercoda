Via the [STAC browser](https://radiantearth.github.io/stac-browser/#/external/{{TRAFFIC_HOST1_81}}/stac/collections/sentinel-2-iceland) you will be able to directly see a visualization of the image, this is because the data samples we are using have data on COG (optimized GeoTIFF) and thus can be simply queried and visualized by the STAC Browser, but if this is not the case, or if you do not want to just visualize the data but do some basic analytics on top of it, we need an engine to provide the EOEPCA

Explain that the rasrter and vector

deploy the raster and vector

helm upgrade -i eoapi eoapi/eoapi --version 0.7.5 \
  --namespace data-access \
  --create-namespace \
  --values eoapi/generated-values.yaml \
  --set browser.enabled=false --set docServer.enabled=false \
  --set stac.enabled=true \
  --set raster.enabled=true --set vector.enabled=true \
  --set multidim.enabled=false \

if both togheter they do not work, we can split and first demo the raster and then demo the vector
