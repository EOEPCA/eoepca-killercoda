
Welcome to the tutorial for deploying the EOEPCA Processing Building Block with **OpenEO ArgoWorkflows**.

**OpenEO ArgoWorkflows** provides a Kubernetes-native implementation of the OpenEO API specification, using [Argo Workflows](https://argoproj.github.io/workflows/) to orchestrate batch jobs and [Dask](https://www.dask.org/) for the distributed computation. It's an alternative to the GeoTrellis backend covered in the sibling OpenEO tutorial.

This tutorial will guide you through:

- Deploying the OpenEO ArgoWorkflows API together with its PostgreSQL, Redis, Argo Workflows and Dask Gateway dependencies.
- Configuring OIDC authentication through the EOEPCA IAM Building Block.
- Deploying the EOEPCA Resource Discovery Building Block as a STAC data source, and registering a small Sentinel-2 sample.
- Exploring the OpenEO API and submitting a batch processing job.
- Monitoring the Argo Workflow and Dask execution.

This tutorial assumes basic familiarity with Kubernetes and EOEPCA.
