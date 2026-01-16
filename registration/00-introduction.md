Welcome to the **[EOEPCA Resource Registration](https://eoepca.readthedocs.io/projects/resource-registration/en/latest/)** building block tutorial!

The Resource Registration service allows for resources to be added to the system in a way which goes beyond individual registration using the STAC transactions API in the Resource Discovery Building Block. This includes ongoing and bulk resource registration via asynchronous APIs and harvesting.

In this scenario, you will learn how to deploy and interact with the EOEPCA Resource Registration Building Block.

---

### What You'll Learn

- Deploy the Resource Registration building block on Kubernetes
- Trigger ingest of an externally-hosted STAC Collection
- Harvest a small subset of Landsat and Sentinel data

---

### Use Case

The Resource Registration Building Block is intended to help you integrate dataset data and metadata from elsewhere into your platform.

---

### Assumptions

Before we start, you should note that this tutorial assumes a generic knowledge of EOEPCA pre-requisites (Kubernetes, Object Storage, etc...) and some tools installed on your environment (gomplate, minio client, etc...). If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial.
