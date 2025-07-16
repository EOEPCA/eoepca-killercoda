The Data Access Building block is implemented by [eoapi](https://github.com/developmentseed/eoAPI). First thing first, we need then to install the eoapi helm repository

```
helm repo add eoapi https://devseed.com/eoapi-k8s/
helm repo update eoapi
```{{exec}}

The Building block is composed by several sub-components, which can be deployed togheter or one after the other. As explained in the [Data Access BB Architecture](https://eoepca.readthedocs.io/projects/data-access/en/latest/design/overview/), these are:
- [STAC-FastAPI-PgSTAC](https://github.com/stac-utils/stac-fastapi-pgstac), which provides STAC storage with PgSTAC for Postgres and STAC API
- [STAC Manager](https://github.com/developmentseed/stac-manager), which provides an UI to edi STAC Collections and items
- [TiTiler-PgSTAC](https://github.com/stac-utils/titiler-pgstac) and [TiPg](https://github.com/developmentseed/tipg), which provide raster and vector data visualization via [OGC WFS](https://www.ogc.org/publications/standard/wfs/), [OGC API Features](https://ogcapi.ogc.org/features/), [OGC WMTS](https://www.ogc.org/standards/wmts/) and [OGC API Tiles](https://ogcapi.ogc.org/tiles/)
- [TiTiler-OpenEO](https://github.com/sentinel-hub/titiler-openeo), which provides [OpenEO](https://openeo.org/) Synchronous API extensions on top of Titiler 
- <span style="color:red">beta</span>[TiTiler-Multidim](https://github.com/developmentseed/titiler-multidim), which provides visualization support extensions for XArray
- <span style="color:red">beta</span>[TiTiler-Maps-Plugin](https://github.com/EOEPCA/eoapi-maps-plugin), which provides [OGC Maps](https://ogcapi.ogc.org/maps/) support

In this tutorial we will deploy and explain them one-by-one.

The first component we will deploy is the STAC Catalogue. This is an alternative implementation respect to the STAC Catalogue provided by the [Resource Discovery](https://eoepca.readthedocs.io/projects/resource-discovery/en/latest/) Building Block, following the same STAC interfaces. Respect to the [Resource Discovery](https://eoepca.readthedocs.io/projects/resource-discovery/en/latest/), the STAC Catalogue included in the data access is tailored to only data (raster and vector), not generic metadata (e.g. documents, code, projects, etc...), and supports only the STAC interface, without any other catalogue interface (e.g. [OGC Records](https://ogcapi.ogc.org/records/) and [OGC CSW](https://www.ogc.org/standards/cat/)) implemented.

To deploy only the STAC catalogue component from eoapi, we need to disable all the other sub-components while enabling the `stac`{{}} sub-component, via

```
helm upgrade -i eoapi eoapi/eoapi --version 0.7.5 \
  --namespace data-access \
  --create-namespace \
  --values eoapi/generated-values.yaml \
  --set browser.enabled=false --set docServer.enabled=false \
  --set stac.enabled=true \
  --set raster.enabled=false --set vector.enabled=false \
  --set multidim.enabled=false \
```{{exec}}

We need now to wait for the catalogue to go up. To do so we can run

```
kubectl --namespace data-access wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

