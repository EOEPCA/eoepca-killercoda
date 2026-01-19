
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

---

Navigate to the Application Quality configuration scripts:

```
cd ../application-quality
```{{exec}}

And check for prerequisites

```
bash check-prerequisites.sh
```{{exec}}

