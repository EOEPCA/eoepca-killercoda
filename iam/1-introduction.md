Welcome to the [EOEPCA Identity and Access Management (IAM)](https://eoepca.readthedocs.io/projects/iam/en/latest/) Building Block Tutorial

The EOEPCA Identity and Access Management (IAM) Building Block comprises two main aspects:
- [Keycloak](https://www.keycloak.org/) is the main Identity Provider, handling things like logging in, user roles, and connecting to other identity systems. 
- OPA (with [OPAL](https://opal.ac/)) is used for making detailed policy decisions

In addtion, the IAM request authorization approach relies upon [APISIX](https://apisix.apache.org/) which acts as the API gateway that routes requests and enforces authorization policies defined in Keycloak and/or OPA.

The focus of this tutorial is the deployment of Keycloak and OPA as an integrated IAM solution - with demonstrations of access protection and policy enforcement.

Before we start, you should note that this tutorial assumes a generic knowledge of EOEPCA pre-requisites (Kubernetes, Object Storage, etc...) and some tools installed on your environment (gomplate, minio client, etc...). In particular, it relieas on the APISIX Ingress Controller, which is a pre-requisite for enabling authorization on the EOPEPCA Building Blocks. If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="../../scenario/prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial.

