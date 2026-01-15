Welcome to the **[EOEPCA Data Gateway](https://eoepca.readthedocs.io/projects/architecture/en/latest/reference-architecture/data-gateway-BB/)** building block tutorial!

The Data Gateway provides a consolidated and consistent capability for accessing Earth Observation data from an extensible set of providers and datasets. Unlike other EOEPCA building blocks that require deployment, the Data Gateway is implemented through **EODAG** (Earth Observation Data Access Gateway) a Python library and command-line tool.

---

### Use Case

Imagine you're building a processing workflow that needs SENTINEL2 imagery. Rather than implementing separate integrations for Copernicus Data Space, AWS, or other providers, you can use the Data Gateway (EODAG) as a unified interface. Your code searches and retrieves data the same way regardless of the underlying provider.

---

### Key Concepts

- **EODAG**: The underlying library implementing the Data Gateway functionality
- **Providers**: External data sources (Copernicus Data Space, AWS, USGS, etc.)
- **Collections/Product Types**: Categories of EO data (SENTINEL2 L1C, Landsat-8, etc.)
- **STAC**: SpatioTemporal Asset Catalog standard for metadata

---

### Note

This tutorial focuses on using EODAG directly. In a full EOEPCA deployment, the Data Gateway capabilities are typically consumed by other building blocks rather than accessed standalone. However, understanding EODAG's features helps you appreciate how data access works across the platform.