
Welcome to the tutorial for deploying EOEPCA Processing Building Block with OpenEO ArgoWorkflows and Dask.

**OpenEO ArgoWorkflows** provides a Kubernetes-native implementation of the OpenEO API specification using Dask for distributed processing. This offers an alternative to the GeoTrellis backend, leveraging Dask's parallel computing capabilities for Earth observation data processing.

This tutorial will guide you through:
- Deploying the OpenEO API with PostgreSQL and Redis
- Setting up authentication without OIDC (for demo purposes)
- Deploying a mock STAC catalogue
- Fixing a known issue with the executor image
- Running a complete job through the system

This tutorial assumes basic understanding of Kubernetes.