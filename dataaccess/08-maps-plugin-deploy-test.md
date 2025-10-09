```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev

helm upgrade -i eoapi-maps-plugin eoepca-dev/eoapi-maps-plugin \
  --version 0.0.21 \
  --namespace data-access \
  --values eoapi-maps-plugin/generated-values.yaml
```{{exec}}


