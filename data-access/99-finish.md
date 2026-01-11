
We have learned in this tutorial how to deploy and use the EOEPCA Data Access Building Block.

### Key Concepts

- **STAC (SpatioTemporal Asset Catalog)**: A specification for cataloguing Earth Observation data with standardised metadata
- **eoAPI**: A suite of microservices providing STAC, raster, vector, and multidimensional data access
- **TiTiler**: Dynamic tile server for serving imagery as map tiles
- **pgSTAC**: PostgreSQL extension optimised for STAC metadata storage and querying
- **OGC APIs**: Standard interfaces for geospatial data access (Features, Tiles, Maps, Coverages)

### What We Deployed

- STAC API for metadata discovery and search
- Raster API for dynamic tile generation
- Vector API for feature data access
- Multidimensional API for Zarr/NetCDF data
- STAC Manager for web-based administration
- PostgreSQL with PostGIS and pgSTAC

### What We Demonstrated

- Loading a Sentinel-2 collection into the catalogue
- Searching for items by location and time
- Accessing imagery metadata and assets
- Using the various API endpoints

You can now play more with the deployed software, loading additional collections or exploring the APIs further, or jump to another one of the [EOEPCA Tutorials](https://killercoda.com/eoepca/).

For more information about EOEPCA and the Data Access Building Block, and more advanced deployments (including OIDC authentication with Keycloak), have a look at:

- [EOEPCA Website](https://eoepca.org/)
- [EOEPCA Git Repository](https://github.com/EOEPCA/)
- [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/)
- [General EOEPCA Documentation](https://eoepca.readthedocs.io/)
- [EOEPCA Data Access Building Block Documentation](https://eoepca.readthedocs.io/projects/data-access/en/latest/)
- [eoAPI Documentation](https://eoapi.dev/)
- [STAC Specification](https://stacspec.org/)
- [TiTiler Documentation](https://developmentseed.org/titiler/)

And if you have questions about this tutorial, EOEPCA in general or specific EOEPCA applications, contact us at [Eoepca.SystemTeam@telespazio.com](mailto:Eoepca.SystemTeam@telespazio.com)