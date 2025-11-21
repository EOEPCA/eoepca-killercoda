
Continuing with the OpenEO configuration, we need to set up data access parameters.

The S3 endpoint we'll use for storing outputs is the local S3 storage, which was already configured in the pre-requisites. We don't need to update its configuration (endpoint, access key, secret key and region):

```
no
no
no
no
```

For STAC catalog integration (which provides the data collections), we'll use a demo catalog for now:

```
https://earth-search.aws.element84.com/v1
```

Now the script asks if we want to enable authentication via OpenID Connect. This is recommended for production deployments to control user access. For this basic demo, we'll disable it:

```
false
```

Configure the OpenEO processes to be available. The dask backend supports a subset of OpenEO processes. We'll use the default set:

```
default
```

For worker resource allocation, we need to specify the default resources for Dask workers. Use moderate values for the demo:

```
2
4Gi
```

We've completed the OpenEO configuration and our values are ready. You can check them with:

```bash
less generated-values.yaml
```

NOTE: Press `q` to exit when you're done inspecting the file, and we can move to the next step.