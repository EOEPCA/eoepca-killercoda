
Welcome to the EOEPCA Processing Building Block, [OpenEO API](https://openeo.org/), Dask distributed backend tutorial!

EOEPCA provides different data processing solutions tailored to different use cases. Interactive data processing tasks and data analytics are typically performed via the [OpenEO API](https://api.openeo.org/) interface, whilst bulk data processing and systematic processing operations use the [OGC Process API](https://ogcapi.ogc.org/processes/) interface.

OpenEO provides a standardised API for Earth Observation data processing that allows users to:
- Access and filter large EO data collections
- Apply processing chains using standardised processes
- Execute processing in a scalable, distributed manner
- Export results in various formats

This tutorial focuses on deploying an [OpenEO API](https://openeo.org/) interface using the [openeo-processes-dask](https://github.com/EOEPCA/openeo-processes-dask) backend, which leverages [Dask](https://www.dask.org/) for distributed computing on Kubernetes clusters.

The Dask backend provides:
- Distributed processing across multiple workers
- Lazy evaluation for optimised computation graphs
- Integration with standard geospatial libraries (xarray, rasterio, geopandas)
- Dynamic scaling based on workload

Before we start, note that this tutorial assumes a general knowledge of EOEPCA pre-requisites (Kubernetes, Object Storage, etc.) and some tools installed on your environment (gomplate, minio client, etc.). If you want to know more about what's needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="../../scenario/prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial.