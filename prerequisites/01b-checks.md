Most of the EOEPCA deployment explained in the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) is assisted by the Deployment Guide scripts available on te [EOEPCA Deployment Guide Github](https://github.com/EOEPCA/deployment-guide/).

Thus, we can download and uncompress the **eoepca-2.0-rc1** version of the EOEPCA Deployment Guide, to which this tutorial refers. This contains the deployment scripts we will use for our EOEPCA deployment

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc1 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

In the Deployment Guide scripts there is a special script for checking if the Kubernetes and infrastructure prerequisites are met. Let's run it now:
```
cd ~/deployment-guide/scripts/infra-prereq
bash check-prerequisites.sh
```{{exec}}

As you can see we got an error, because the `gomplate`{{}} software is not installed in our environment. To install it, we can follow the guide and run:

```
curl -L -o gomplate https://github.com/hairyhenderson/gomplate/releases/download/v4.3.0/gomplate_linux-amd64
chmod +x gomplate
sudo mv gomplate /usr/local/bin/
```{{exec}}

Now we can run the check-prerequisite again via

```
bash check-prerequisites.sh
```{{exec}}

And we are faced with some questions about the configuration we are going to use - this will be explained in details in the next steps:
- Nginx ingress controller
  ```
  nginx
  ```{{exec}}
- HTTP scheme for the EOEPCA services
  ```
  http
  ```{{exec}}
- Base domain
  ```
  eoepca.local
  ```{{exec}}
- Kubernetes storage class for persistent volumes
  ```
  standard
  ```{{exec}}
- Automatic certificate issuance with cert-manager
  ```
  yes
  ```{{exec}}
- Cert Manager cluster issuer for TLS certificates (this is the name of the ClusterIssuer we will configure later in Cert-Manager)
  ```
  eoepca-ca-clusterissuer
  ```{{exec}}
- `no` to the other two questions since these values are already set
  ```
  no
  no
  ```{{exec}}

--- 

From the results of our pre-requisites check:
1. Pods can run as `root` - we will check that in details in one of our next steps
2. Could not reach ingress - ingress controller is not installed
3. No ClusterIssuer found - Cert-Manager is not deployed and configured
4. PVC did not bind with RWX - No ReadWriteMany storage class available for instantiating Persistent Volume Claims

We will address these issues in the next steps.
