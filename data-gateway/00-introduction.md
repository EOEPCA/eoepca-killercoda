Welcome to the **[EOEPCA Data Gateway](https://eoepca.readthedocs.io/projects/architecture/en/latest/reference-architecture/data-gateway-BB/)** building block tutorial!

The Data Gateway provides a consolidated and consistent capability for accessing Earth Observation data from an extensible set of providers and datasets. Unlike other EOEPCA building blocks that require deployment, the Data Gateway is implemented through **EODAG** (Earth Observation Data Access Gateway) — a Python library and command-line tool that other components integrate directly.

---

### What You'll Learn

- Install and configure EODAG
- Explore available data providers and product types
- Search for EO products using the CLI and Python API
- Run EODAG as a STAC-compliant REST API server
- Understand how the Data Gateway integrates with other EOEPCA building blocks

---

### Use Case

Imagine you're building a processing workflow that needs Sentinel-2 imagery. Rather than implementing separate integrations for Copernicus Data Space, AWS, or other providers, you can use the Data Gateway (EODAG) as a unified interface. Your code searches and retrieves data the same way regardless of the underlying provider.

The Data Gateway is used by other EOEPCA building blocks:
- **Resource Registration**: Uses it for harvesting from external catalogues
- **Processing Engine**: Leverages it for input data preparation and access
- **Data Access**: Employs it for retrieving dataset assets for visualisation services

---

### Key Concepts

- **EODAG**: The underlying library implementing the Data Gateway functionality
- **Providers**: External data sources (Copernicus Data Space, AWS, USGS, etc.)
- **Collections/Product Types**: Categories of EO data (Sentinel-2 L1C, Landsat-8, etc.)
- **STAC**: SpatioTemporal Asset Catalog standard for metadata

---

### Note

This tutorial focuses on using EODAG directly. In a full EOEPCA deployment, the Data Gateway capabilities are typically consumed by other building blocks rather than accessed standalone. However, understanding EODAG's features helps you appreciate how data access works across the platform.