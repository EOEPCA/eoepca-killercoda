
As with other EOEPCA building blocks, we'll use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to configure and deploy the Application Quality BB.

First, download the deployment guide repository:

```
git clone https://github.com/EOEPCA/deployment-guide --branch release-2-jh
```{{exec}}

Now set up internal TLS for the EOEPCA services:

```
cd deployment-guide/scripts/internal-tls
bash setup-internal-tls.sh
```{{exec}}

When prompted, provide the following configuration values.

We're not using TLS certificates in this demo, so select the `http` scheme:
```
http
```{{exec}}

For the ingress controller, we'll use nginx (the simpler option for this demo):
```
nginx
```{{exec}}

Enter the top-level domain for EOEPCA services:
```
eoepca.local
```{{exec}}

Storage class:
```
local-path
```{{exec}}

We don't need automatically generated certificates:
```
no
```{{exec}}

This configures cert-manager and creates necessary secrets for internal TLS communication.

Now navigate to the Application Quality deployment scripts:

```
cd ../application-quality
```{{exec}}

Check that prerequisites are met:

```
bash check-prerequisites.sh
```{{exec}}
