Welcome to the tutorial for deploying the EOEPCA Application Hub Building Block.

The **Application Hub** gives platform users a browser-based working environment on the platform's Kubernetes cluster. It is built on JupyterHub: a user logs in, picks a **profile**, and the Hub starts that profile as a pod in a namespace of the user's own.

A Platform Operator defines the profiles. Each one sets:

- the container image - JupyterLab, Code Server, a remote desktop or any other web application
- the CPU and memory limits, and the nodes the pod may run on
- the persistent workspace mounted into it
- the configuration and credentials files placed in the user's home directory
- the groups whose members are offered it

By the end of this tutorial, you will have:
- Deployed the Application Hub with OIDC authentication via Keycloak
- Created groups and used them to control which profiles a user is offered
- Spawned a dashboard and a JupyterLab session, and inspected what the Hub created for the user
- Written a file to the user's persistent workspace and found it again after restarting the server

This tutorial assumes basic familiarity with Kubernetes and the EOEPCA system.
