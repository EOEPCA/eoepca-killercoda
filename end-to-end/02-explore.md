Check the cluster:
```
kubectl get pods -A
```{{exec}}

Check the pre-loaded datacube-ready collection on the Data Access BB's STAC API:
```
curl -s "http://eoapi.eoepca.local/stac/collections/sentinel-2-datacube" | jq '{id, title, "cube:dimensions": .["cube:dimensions"] | keys}'
```{{exec}}

Check IAM:
```
curl -s "http://auth.eoepca.local/realms/eoepca/.well-known/openid-configuration" | jq '.issuer'
```{{exec}}

