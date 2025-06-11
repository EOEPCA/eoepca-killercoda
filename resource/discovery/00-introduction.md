Welcome to the **[EOEPCA Resource Discovery](https://eoepca.readthedocs.io/projects/resource-discovery/en/latest/)** building block tutorial!

The Resource Discovery serivce plays a key role in enabling users and services to search, discover, and access data assets using standard web APIs.

In this scenario, you will learn how to deploy and interact with the EOEPCA Resource Discovery — a core component responsible for exposing Earth Observation datasets and services through metadata that complies with the [STAC (SpatioTemporal Asset Catalog)](https://stacspec.org/en) standard.

---

### What You'll Learn

- Deploy Resource Discovery building block on Kubernetes
- Register a STAC-compliant dataset into the catalogue
- Search the catalogue with spatial and temporal filters via the STAC API
- Use Swagger UI to explore and interact with the API

---

### Use Case

Imagine you've just ingested a new Sentinel-2 satellite scene into your system. To make it discoverable by other users or services, you publish the metadata into the Resource Catalogue using the STAC format.

Once published, other users can query it by:
- Region of interest (bounding box)
- Date range
- Data collection or mission

This tutorial simulates that workflow end-to-end.

---

Let’s begin by making sure all required tools are installed.
