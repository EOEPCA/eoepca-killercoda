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

Keep the existing domain, persistent storage class, and shared ReadWriteMany storage class:

```
no
no
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

Use the same S3 service for stage-in and stage-out:

```
no
```{{exec}}

The script now asks whether to enable OpenID Connect authentication. This is strongly recommended for a shared processing API, because otherwise every user able to reach it can deploy and run processing applications.

For this isolated tutorial, disable it:

```
false
```{{exec}}

The general ZOO-Project configuration is complete. In the next step, we configure the processing engine.
