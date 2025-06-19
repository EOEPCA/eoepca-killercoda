Welcome to the **[EOEPCA Resource Discovery](https://eoepca.readthedocs.io/projects/resource-discovery/en/latest/)** building block tutorial!

The Resource Discovery service plays a key role in enabling users and services to search, discover, and access data assets using standard web APIs.

In this scenario, you will learn how to deploy and interact with the EOEPCA Resource Discovery — a core component responsible for exposing Earth Observation datasets and services through metadata that complies with the [STAC (SpatioTemporal Asset Catalog)](https://stacspec.org/en) standard.

---

### What You'll Learn

- Deploy Resource Discovery building block on Kubernetes
- Register a STAC-compliant dataset into the catalogue
- Search the catalogue with spatial and temporal filters via the STAC API
- Use Swagger UI to explore and interact with the API

---

### Use Case

Imagine you've just several EO Satellite images or value added products or just any other products and you want to make them discoverable by your users or services, you publish the metadata into the Resource Catalogue using the STAC format.

Once published, other users can query it by:
- Region of interest (bounding box)
- Date range
- Data collection or mission

and see all the data information, download the data or process it using the [EOEPCA Processing Building Block](https://eoepca.readthedocs.io/projects/processing/en/latest/)

This tutorial simulates the deployment of the data catalogue, the registration of some sample data and the discovery of such data.

Note that the registration shown here is a very simple single product registration. For automatic registration of common EO datasets and to perform all data management operations (e.g. keep the datasets in sync), the [EOEPCA Resource Registration Building Block](https://eoepca.readthedocs.io/projects/resource-registration/en/latest/) is provided.

---

### Assumptions

Before we start, you should note that this tutorial assumes a generic knowledge of EOEPCA pre-requisites (Kubernetes, Object Storage, etc...) and some tools installed on your environment (gomplate, minio client, etc...). If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the [EOEPCA Pre-requisites](../prerequisites) tutorial.

