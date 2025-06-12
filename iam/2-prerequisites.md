## Prerequisite and Initial Configuration


Before deploying the IAM components, ensure your environment is ready. This scenario provides a Kubernetes cluster (v1.28+) with **kubectl** access, **Helm 3**, an **APISIX** ingress controller and **cert-manager**: already set up.

**Clone Deployment Scripts:** First, clone the EOEPCA Deployment Guide repository to get the helper scripts and navigate to the IAM scripts directory:

```bash
git clone https://github.com/EOEPCA/deployment-guide.git -b feature/rconway-updates

cd deployment-guide/scripts/iam
```{{exec}}

Before deploying the IAM components, you need to ensure your environment is properly configured. The following command runs a script that checks for all necessary prerequisites. The script normally prompts you for several configuration values, but in this tutorial, we provide them automatically for convenience.

```bash
bash check-prerequisites.sh <<EOF
http
apisix
eoepca.local:31080
local-path
no
EOF
```{{exec}}

**What these values mean:**

1. **HTTP scheme**: `http`{{}}
   The protocol to use for ingress traffic.
2. **Ingress class**: `apisix`{{}}
   Specifies the ingress controller (here, APISIX) that will manage external access.
3. **Ingress host**: `eoepca.local:31080`{{}}
   The hostname through which the services will be accessed.
4. **Storage class**: `local-path`{{}}
   The Kubernetes storage class to use for persistent data.
5. **Cert-manager enabled**: `no`{{}}
   Indicates whether certificate management is enabled (set to `no`{{}} for this tutorial).

You can set them to different values following the configuration prompts as they appear.
