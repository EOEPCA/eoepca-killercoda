Explain that the STAC manager is an utility to edit the STAC

Put here the deploy of the stac manager

```
helm repo add stac-manager https://stac-manager.ds.io/
helm repo update stac-manager
helm upgrade -i stac-manager stac-manager/stac-manager \
  --version 0.0.11 \
  --namespace data-access \
  --values stac-manager/generated-values.yaml
```{{exec}}

then connecting it via the UI to do some STAC editing stuff

[this link works]{{}}

then undeploy the STAC manager

