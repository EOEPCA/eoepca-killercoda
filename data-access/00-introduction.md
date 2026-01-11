Welcome to the **[EOEPCA Data Access](https://eoepca.readthedocs.io/projects/data-access/en/latest/)** building block tutorial!

The Data Access Building Block provides feature-rich and reliable interfaces to geospatial data assets stored in the platform, addressing both human and machine users. It enables discovery, visualisation, and retrieval of Earth Observation data through standard OGC APIs.

In this scenario, you will learn how to deploy and interact with the EOEPCA Data Access Building Block — a core component for serving satellite imagery and geospatial data via STAC and OGC APIs.

---

### What You'll Learn

- Deploy the Data Access building block on Kubernetes
- Load a sample Sentinel-2 collection into the STAC catalogue
- Query the STAC API for metadata discovery
- Access raster tiles and visualise imagery
- Use the STAC Manager UI for catalogue administration

---

### Use Case

Imagine you're building an Earth Observation platform that needs to serve satellite imagery to researchers and applications. You need standardised APIs for data discovery and access.

With Data Access, you can:
- Catalogue Earth Observation data using STAC (SpatioTemporal Asset Catalog)
- Serve raster imagery via dynamic tile APIs
- Provide vector data access through OGC API Features
- Support multidimensional data formats like Zarr and NetCDF
- Manage your catalogue through a web-based administration interface

This tutorial deploys the Data Access services, loads sample Sentinel-2 data from Iceland, and demonstrates how to query and visualise the data.

---

### Components Overview

The Data Access BB includes:
- **STAC API** — Metadata catalogue for discovering Earth Observation data
- **Raster API** — Dynamic tile generation via TiTiler for imagery visualisation
- **Vector API** — OGC API Features for vector data access
- **Multidim API** — Access to multidimensional datasets (Zarr, NetCDF)
- **STAC Manager** — Web interface for catalogue administration
- **PostgreSQL + pgSTAC** — Database backend for metadata storage

---

### Assumptions

This tutorial assumes a generic knowledge of EOEPCA prerequisites (Kubernetes, Object Storage, etc.) and some tools installed on your environment (gomplate, etc.). If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial.

This tutorial deploys Data Access in a simplified mode without OIDC authentication, suitable for demonstration purposes.