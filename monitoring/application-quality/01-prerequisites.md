
As with other EOEPCA building blocks, we'll use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to configure and deploy the Application Quality BB.

First, clone the **release-2.1** branch of the deployment guide repository:

<!-- TODO(release-2.1): once the eoepca-2.1 tag is published, revert this step to the tarball
     download: curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.1 | tar zx
     --transform 's|^EOEPCA[^/]*|deployment-guide|' -->
```
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
```{{exec}}

Now set up internal TLS for the EOEPCA services:

```
cd deployment-guide/scripts/internal-tls
bash setup-internal-tls.sh
```{{exec}}

Keep `eoepca.local`{{}} as the local domain shared by the EOEPCA services:
```
n
```{{exec}}

Use `local-path`{{}} to provide persistent Kubernetes volumes inside this tutorial environment:
```
local-path
```{{exec}}

Disable automatic certificate generation, since Localcoda provides the tutorial's external HTTPS proxy:
```
no
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

