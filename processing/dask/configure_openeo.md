
Before proceeding with the OpenEO backend deployment, we need to configure it. We can do this with the help of the EOEPCA deployment guide configuration script:

```bash
bash configure-openeo.sh
```

The script will start with the general EOEPCA configuration.

For the demo deployment we aren't generating certificates, so we'll restrict ourselves to the http scheme:

```
http
```

As mentioned previously, we'll use the nginx ingress in this demo deployment:

```
nginx
```

As a domain, we use eoepca.local, which is mapped to the local machine in this demo:

```
eoepca.local
```

Our storage class was already set up to 'standard' in the step before, so we don't need to update it:

```
no
```

As we have http only services, we don't need certificate generation (which wouldn't work in this demo environment anyway):

```
no
```

We now move to the OpenEO specific configuration. First, we need to specify the backend type - we'll use dask:

```
dask
```

For the Dask backend, we need to configure the connection to our Dask Gateway. Use the gateway we deployed earlier:

```
http://dask-gateway.dask:80
```

For authentication to the Dask Gateway (as configured in our deployment):

```
dask-gateway-password
```
