## Prerequisite and Initial Configuration

Before deploying the IAM components, ensure your environment is ready. This scenario provides a Kubernetes cluster (v1.28+) with **kubectl** access, **Helm 3**, and an **APISIX** ingress controller already provisioned.

**Clone Deployment Scripts**

First, clone the EOEPCA Deployment Guide repository to get the helper scripts and navigate to the IAM scripts directory:

```bash
git clone https://github.com/EOEPCA/deployment-guide.git -b feature/rconway-updates

cd deployment-guide/scripts/iam
```{{exec}}

**Check IAM Prerequisites**

Before deploying the IAM components, you need to ensure your environment is properly configured. The following command runs a script that checks for all necessary prerequisites. The script prompts for information that reflects the intended configuration of your deployment.

```bash
bash check-prerequisites.sh
```{{exec}}

For this tutorial we define some values that are consistent with the local tutorial environment:<br>
_Select the provided values to inject them into the terminal prompts_

* HTTP scheme: `http`{{exec}}<br>
  The protocol to use for ingress traffic - see also `Cert-manager enabled`
* Ingress class: `apisix`{{exec}}<br>
  The name of the ingress controller that handles incoming requests.<br>
  For this tutorial we use the APISIX Ingress Controller, which has already been provisioned within this environment.
* Base domain: `eoepca.local`{{exec}}<br>
  The base part of the hostnames through which the deployed services are accessed.
* Storage class: `local-path`{{exec}}
  The name of the storage class for the dynamic provisioning of volumes for persistence.<br>
  The tutorial environment provides a simple `local-path` provisioner.
* Cert-manager enabled: `no`{{exec}}
  Indicates whether `Cert Manager` should be used for provisioning of TLS certificates for service ingress.<br>
  For simplicity, the tutorial uses only http.
