Welcome to the tutorial for deploying the EOEPCA Application Hub Building Block.

The **Application Hub** provides a suite of web-based tools for interactive analysis and application development on Earth Observation (EO) data. Built on JupyterHub and Kubernetes, it delivers:

- **JupyterLab** for interactive data analysis and notebook execution
- **Code Server** for browser-based development environments
- **Custom dashboards** and interactive web applications
- **Multi-user support** with profile-based resource allocation
- **Group-based access control** for different user categories

By the end of this tutorial, you will have:
- Deployed the Application Hub with OIDC authentication via Keycloak
- Created groups and used them to control which profiles a user is offered
- Spawned a dashboard and a JupyterLab session, and inspected what the Hub created for the user
- Written a file to the user's persistent workspace and found it again after restarting the server

This tutorial assumes basic familiarity with Kubernetes and the EOEPCA system.