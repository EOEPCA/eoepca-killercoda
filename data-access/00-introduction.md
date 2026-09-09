The **[EOEPCA Data Access](https://eoepca.readthedocs.io/projects/data-access/en/latest/)** building block serves Earth Observation data through STAC and OGC APIs.

In this tutorial you will:

- Deploy eoAPI, PostgreSQL, STAC Manager and titiler-openeo using the deployment guide.
- Load a Sentinel-2 catalogue covering Iceland.
- Search for a clear summer scene near Reykjavík.
- Render true-colour and spectral-band previews, and explore a collection mosaic.
- Update collection metadata and inspect the change in STAC Manager and STAC Browser.

The sample catalogue links to public Cloud Optimised GeoTIFFs. Data Access reads these files when you request imagery.

### Services

- **STAC API** — catalogue discovery and transactions, backed by PostgreSQL and pgSTAC.
- **Raster API** — previews, tiles and mosaics from raster assets.
- **STAC Browser** — visual catalogue exploration.
- **STAC Manager** — catalogue browsing and administration.
- **Vector API** — OGC API Features for vector data.
- **Multidimensional API** — access to formats such as Zarr and NetCDF.
- **titiler-openeo** — raster processing through an openEO interface.

### Environment

Localcoda supplies Kubernetes, NGINX ingress and MinIO. For deployment on your own infrastructure, follow the [EOEPCA prerequisites](https://eoepca.readthedocs.io/projects/deploy/en/latest/prerequisites/).

This tutorial runs without IAM. STAC reads and transactions are unauthenticated; openEO processing requires the credentials generated during configuration.
