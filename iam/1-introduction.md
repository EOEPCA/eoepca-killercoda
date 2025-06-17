
**Overview:** 

The EOEPCA Identity and Access Management (IAM) Building Block comprises two main aspects:
- Keycloak is the main Identity Provider, handling things like logging in, user roles, and connecting to other identity systems. 
- OPA (with OPAL) is used for making detailed policy decisions

In addtion, the IAM request authorization approach relies upon APISIX which acts as the API gateway that routes requests and enforces authorization policies defined in Keycloak and/or OPA.

The focus of this tutorial is the deployment of Keycloak and OPA as an integrated IAM solution - with demonstrations of access protection and policy enforcement.

The deployment of the APISIX Ingress Controller has already been triggered as a prerequisite dependency of this tutorial.

Please wait until the APISIX deployment has completed, as indicated by the terminal messages.
