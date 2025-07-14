Before proceeding with the Data Acces Building Block deployment, we need first to configure it. We can do it with the configuration script `configure-data-access.sh` provided in the EOEPCA dployment guide.
```
bash configure-data-access.sh
```{{exec}}

The script will start with the general EOEPCA configuration and move on sto the now the Resource Discovery building block specific configuration. We do not need to update domain and storage class, we will use what's already set, so we answer `no` to both questions:
```
no
no
```{{exec}}

We do not use MinIO S3 Storage in our tutorial, nevertheless it is necessary to give the name of the S3 host:
```
minio.eoepca.local
```{{exec}}

We do not want to update previously set values for S3_ACCESS_KEY and S3_SECRET_KEY, they won't be used anyway:
S3_ACCESS_KEY is already set to 'eoepca'. Do you want to update it
```
no
no
```{{exec}}

<!--
Finally, we create a Kubernetes secret with S3 credentials. Also here a script is provided in the Deployment Guide.
```
bash apply-secrets.sh
kubectl -n data-access get secrets
```{{exec}}
-->

Now, since our Kubernetes cluster comprises only one node with limited resources, we must adjust the deployment configuration to the platform constraints such as memory limits. We will also use the Postgres database that was preinstalled on the host from the distribution package instead of one deployed in a pod (which is the default). Finally, we can turn on or off deployment of certain components of the Building Block.

These changes are not configurable with the `configure-data-access.sh` script and we cannot easily edit the default `values.yaml` of the deployment. The method we use is to patch the file `eoapi/generated-values.yaml` with some extra values from a file  `generated-values-patch.yaml` that was created specifically for this tutorial.
```
source ~/.eoepca/state
yq ea '. as $item ireduce ({}; . *+ $item )' -i eoapi/generated-values.yaml /tmp/assets/eoapi-generated-values-patch.yaml
sed -E -i -e "s|https://(eoapi\|maps)|${HTTP_SCHEME}://\1|g" eoapi-maps-plugin/generated-values.yaml 
yq -i "del .ingress.tls" eoapi-maps-plugin/generated-values.yaml
```{{exec}}

Note, that this is not a solution for production environments.
