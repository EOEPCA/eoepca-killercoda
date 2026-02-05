
As with other EOEPCA building blocks, we'll use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to configure and deploy the Application Quality BB.

First, download the deployment guide repository:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
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

