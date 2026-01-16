Welcome to the tutorial for deploying the EOEPCA Application Hub Building Block.

The **Application Hub** provides a suite of web-based tools for interactive analysis and application development on Earth Observation (EO) data. Built on JupyterHub and Kubernetes, it delivers:

- **JupyterLab** for interactive data analysis and notebook execution
- **Code Server** for browser-based development environments
- **Custom dashboards** and interactive web applications
- **Multi-user support** with profile-based resource allocation
- **Group-based access control** for different user categories

By the end of this tutorial, you will have:
- Deployed the Application Hub with OIDC authentication via Keycloak
- Configured user profiles and groups
- Validated the deployment and spawned a test environment

This tutorial assumes basic familiarity with Kubernetes and the EOEPCA system.