Welcome to the **[EOEPCA Datacube Access](https://eoepca.readthedocs.io/projects/datacube-access/en/latest/)** building block tutorial!

The Datacube Access building block allows users to access and explore multi-dimensional Earth Observation (EO) data using standard APIs. It is built on open standards from OGC (Open Geospatial Consortium) and provides 'pixel-based' access to multidimensional data.

---

### What You'll Learn

- Deploy the Resource Discovery BB as the underlying STAC catalog
- Create and ingest datacube-ready STAC collections
- Deploy the Datacube Access building block on Kubernetes
- Query the Datacube Access API
- Understand how datacube metadata enables analysis-ready data

---

### Use Case

Imagine you have Earth Observation data stored as Cloud-Optimised GeoTIFFs (COGs) and want to provide users with a standardised way to access this data as multi-dimensional datacubes. The Datacube Access BB filters your STAC catalogue to expose only collections that include the STAC Datacube Extension — specifically those with `cube:dimensions` or `cube:variables` defined.

This ensures processing tools like openEO only see properly-structured, analysis-ready collections that can be loaded as xarray datasets.

---

### Key Concepts

- **Datacube**: A multi-dimensional array (x, y, time, bands) with metadata describing its dimensions
- **STAC Datacube Extension**: Adds `cube:dimensions` and `cube:variables` to STAC collections/items
- **OGC GeoDataCube API**: Emerging standard for harmonised access to multidimensional data
- **Analysis-Ready Data**: Data structured for immediate analysis without preprocessing

---

### Architecture

In this tutorial, we will deploy:

1. **Resource Discovery BB**: The STAC catalog that stores and serves metadata
2. **Datacube-Ready Collection**: A STAC collection with datacube extension metadata
3. **Datacube Access BB**: Filters the STAC catalog to expose only datacube collections


### Assumptions

This tutorial assumes familiarity with Kubernetes and Helm. For more details on the Resource Discovery BB, see the dedicated [Resource Discovery Tutorial](https://killercoda.com/eoepca/scenario/resource-discovery).