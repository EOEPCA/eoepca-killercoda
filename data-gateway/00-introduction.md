Welcome to the **[EOEPCA Data Gateway](https://eoepca.readthedocs.io/projects/architecture/en/latest/reference-architecture/data-gateway-BB/)** building block tutorial.

The Data Gateway gives EOEPCA components one consistent way to discover and access Earth Observation data held by many different providers. It is implemented using **EODAG** (Earth Observation Data Access Gateway), an open-source Python library and command-line application.

Unlike the other building blocks in this workshop, there is no Helm deployment in this scenario. We will install EODAG locally and use its three main interfaces:

- the command-line interface for interactive discovery and searches;
- the STAC API for standards-based HTTP integration;
- the Python API for application and processing-workflow integration.

---

### Why a Gateway?

Imagine that a processing workflow needs Sentinel-2 imagery. The same mission may be available from Copernicus Data Space, Earth Search, CREODIAS, or another catalogue, but each provider can expose different APIs, authentication methods, metadata fields, and download mechanisms.

EODAG places a common search and product model in front of those differences. The workflow asks for a product type, area, and time interval; EODAG translates that request for the selected provider and normalises the results.

This does not copy every provider's data into EOEPCA. The gateway remains a client of the upstream catalogues and data stores.

---

### Vocabulary Used in This Tutorial

- **Provider**: An upstream catalogue or data service, such as Earth Search or Copernicus Data Space.
- **Product type**: EODAG's provider-independent identifier for a dataset, such as `S2_MSI_L1C`.
- **Collection**: The STAC term for a group of related items. EODAG exposes product types as STAC collections.
- **Product/item**: One concrete EO acquisition returned by a search.
- **Asset**: A file or service associated with a product, such as a spectral band, thumbnail, or metadata document.
- **STAC**: The SpatioTemporal Asset Catalog specification used to describe and search geospatial assets.

---

### What We Will Validate

All searches in this tutorial use public catalogue endpoints and historical date ranges, so no provider credentials or large downloads are required. We will inspect product metadata and asset links, but deliberately avoid downloading a complete satellite scene during the workshop.
