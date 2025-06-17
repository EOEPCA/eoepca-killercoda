Welcome to the [EOEPCA Identity and Access Management (IAM)](https://eoepca.readthedocs.io/projects/iam/en/latest/) Building Block Tutorial

The EOEPCA Identity and Access Management (IAM) Building Block comprises two main aspects:
- [Keycloak](https://www.keycloak.org/) is the main Identity Provider, handling things like logging in, user roles, and connecting to other identity systems. 
- OPA (with [OPAL](https://opal.ac/)) is used for making detailed policy decisions

In addtion, the IAM request authorization approach relies upon [APISIX](https://apisix.apache.org/) which acts as the API gateway that routes requests and enforces authorization policies defined in Keycloak and/or OPA.

The focus of this tutorial is the deployment of Keycloak and OPA as an integrated IAM solution - with demonstrations of access protection and policy enforcement.

The deployment of the APISIX Ingress Controller has been already performed in the setup of this tutorial. If you want more information about installing APISIX, you can take a look at the [EOEPCA introduction tutorials](../intro) before continuing with this tutorial.

