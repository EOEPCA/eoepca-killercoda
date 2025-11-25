Welcome to the tutorial for deploying EOEPCA Processing Building Block with OpenEO ArgoWorkflows and Dask.

**OpenEO ArgoWorkflows** provides a Kubernetes-native implementation of the OpenEO API specification using Dask for distributed processing. This offers an alternative to the GeoTrellis backend, leveraging Dask's parallel computing capabilities for Earth observation data processing.

By the end of this tutorial, you'll have:
- Deployed OpenEO ArgoWorkflows with PostgreSQL and Redis
- Configured Dask for distributed processing
- Learned to interact with the OpenEO API
- Submitted and monitored Dask-powered processing jobs

Key differences from GeoTrellis:
- Uses Dask instead of Spark for processing
- PostgreSQL and Redis instead of ZooKeeper
- Dynamic worker scaling based on workload
- Python-native processing environment

This tutorial assumes basic understanding of EOEPCA and Kubernetes.