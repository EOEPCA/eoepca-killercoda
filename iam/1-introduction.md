
**Overview:** 

The EOEPCA Identity and Access Management (IAM) Building Block is made up of three main parts: Keycloak, Open Policy Agent (OPA) with OPAL and Apache APISIX. 

- Keycloak is the main Identity Provider, handling things like logging in, user roles, and connecting to other identity systems. 
- OPA (with OPAL) is used for making detailed policy decisions and APISIX acts as the gateway that checks these policies.
- Apache APISIX is the API gateway that routes requests and enforces policies.

In this tutorial, you'll set up the EOEPCA IAM Building Block on a Kubernetes cluster using official scripts and Helm charts. We'll focus just on the IAM parts (Keycloak, OPA/OPAL, APISIX) in a development environment.

This tutorial assumes you already know a bit about EOEPCA and its requirements. If not, it's a good idea to go through the [EOEPCA introduction tutorials](../intro) first.

