Before deploying the building block, configure it with the EOEPCA Deployment Guide script:

```
bash configure-oapip.sh
```{{exec}}

The script starts with the general EOEPCA configuration. The Localcoda environment has already configured the domain, shared storage, and S3 service in `~/.eoepca/state`.

Use the nginx ingress:

```
nginx
```{{exec}}

The domain is already set to `eoepca.local`, so keep it:

```
no
```{{exec}}

For persistent ReadWriteOnce storage, use the default Localcoda storage class:

```
local-path
```{{exec}}

The tutorial uses HTTP only, so disable automatic certificate generation:

```
no
```{{exec}}

We now move to the Processing Building Block configuration.

The shared ReadWriteMany storage class was also already configured by the prerequisites. Keep it:

```
no
```{{exec}}

The local S3 endpoint, access key, secret key, and region were also configured by the prerequisites. Keep all four values:

```
no
no
no
no
```{{exec}}

For this tutorial, store results directly in object storage rather than using the EOEPCA Workspace API:

```
false
```{{exec}}

The script asks whether your inputs are stored in a different S3 store from your outputs. Here they are the same local MinIO, so answer no:

```
no
```{{exec}}

The script now asks whether to enable OpenID Connect authentication. This protection is only available with the APISIX Ingress Controller - since this tutorial uses nginx, disable it:

```
false
```{{exec}}

The general ZOO-Project configuration is complete. In the next step, we configure the processing engine.
