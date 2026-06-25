Welcome to the tutorial for deploying the EOEPCA Processing Building Block with the OpenEO GeoTrellis engine.

**OpenEO** provides a standardised API for simple and unified access to Earth observation cloud backends. In this tutorial, you will build a small but complete deployment on Kubernetes using workshop-friendly settings.

By the end of this tutorial, you will have:

- Configured the deployment using the EOEPCA Deployment Guide.
- Deployed the Spark Operator, ZooKeeper, and the OpenEO GeoTrellis application.
- Exposed the OpenEO API through NGINX Ingress.
- Validated API discovery, demo authentication, and synchronous processing.
- Used the Python OpenEO client to download data and build a process graph.

The image preparation and Helm deployments take several minutes, so wait for each command to finish before continuing. This tutorial assumes basic familiarity with Kubernetes and EOEPCA.
