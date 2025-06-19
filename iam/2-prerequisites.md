## Prerequisite and Initial Configuration

Before deploying the IAM components, ensure your environment is ready. This scenario provides a Kubernetes cluster (v1.28+) with **kubectl** access, **Helm 3**, and an **APISIX** ingress controller already provisioned.

### Download Deployment Scripts

First, we download and uncompress the **eoepca-2.0-rc1b** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc1b | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

and navigate to the deployment scripts

```
cd deployment-guide/scripts/iam
```{{exec}}

### Check IAM Prerequisites

Before deploying the IAM components, you need to ensure your environment is properly configured. The following command runs a script that checks for all necessary prerequisites. The script prompts for information that reflects the intended configuration of your deployment.

```
bash check-prerequisites.sh
```{{exec}}

For this tutorial we define some values that are consistent with the local tutorial environment:<br>
_Select the provided values to inject them into the terminal prompts_

* HTTP scheme: `http`{{exec}}<br>
  We use HTTP to avoid generating trusted certificates for this tutorial
* Ingress class: `apisix`{{exec}}<br>
  The name of the ingress controller that handles incoming requests.<br>
  For this tutorial we use the APISIX Ingress Controller, which has already been provisioned within this environment.
* Base domain: `eoepca.local`{{exec}}<br>
  The base part of the hostnames through which the deployed services are accessed.
* Storage class: `local-path`{{exec}}<br>
  The name of the storage class for the dynamic provisioning of volumes for persistence.<br>
  The IAM component does not need specific storage classes, so we will use the basic local-path provisioner included in this environment.
* Cert-manager enabled: `no`{{exec}}<br>
  Indicates whether *Cert Manager* should be used for provisioning of TLS certificates for service ingress.<br>
  For simplicity, the tutorial uses only http.

### EOEPCA State File

The outcome of the script is a set of environment variables that are maintained in the file `~/.eoepca/state`{{}} . The Deployment Guide scripts rely upon these variables to configure the deployment of the provisioned services.

See how the contents of the EOEPCA state file reflect your inputs:

```
cat ~/.eoepca/state
```{{exec}}
