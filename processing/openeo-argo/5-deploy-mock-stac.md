## Deploy Resource Discovery

OpenEO needs a STAC API from which it can discover input data. Deploy the EOEPCA Resource Discovery Building Block in the same cluster.

### Configure and deploy

Keep the shared workshop domain and storage class:

```bash
cd ~/deployment-guide/scripts/resource-discovery
bash configure-resource-discovery.sh <<EOF
no
no
EOF
```{{exec}}

```bash
helm repo add eoepca https://eoepca.github.io/helm-charts
helm repo update eoepca

helm upgrade -i resource-discovery eoepca/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.0.0 \
  --namespace resource-discovery \
  --create-namespace \
  --set db.volume_access_modes=ReadWriteOnce

kubectl apply -f generated-ingress.yaml
```{{exec}}

Poll the STAC endpoint every 30 seconds, with a five-minute limit:

```bash
for attempt in $(seq 1 10); do
  code=$(curl -s -o /dev/null -w '%{http_code}' \
    http://resource-catalogue.eoepca.local/stac)
  echo "attempt ${attempt}/10: HTTP ${code}"
  [ "${code}" = 200 ] && break
  sleep 30
done
```{{exec}}

```bash
curl -fsS http://resource-catalogue.eoepca.local/stac \
  | jq '{title, description}'
```{{exec}}

## Inspect and ingest a datacube-ready collection

The deployment guide includes a Sentinel-2 collection with the STAC Datacube Extension and two public Cloud-Optimised GeoTIFF items:

```bash
cd ~/deployment-guide/scripts/datacube-access

jq '{
  id,
  title,
  dimensions: (.["cube:dimensions"] | keys),
  variables: (.["cube:variables"] | keys)
}' collections/datacube-ready-collection/collections.json
```{{exec}}

```bash
jq '.[0] | {
  id,
  datetime: .properties.datetime,
  cloud_cover: .properties["eo:cloud_cover"],
  assets: (.assets | keys)
}' collections/datacube-ready-collection/items.json
```{{exec}}

Register the collection. This API returns an empty response body, so check its HTTP status rather than piping it to `jq`:

```bash
curl -sS -o /dev/null -w 'collection: HTTP %{http_code}\n' \
  -X POST \
  -H 'Content-Type: application/json' \
  -d @collections/datacube-ready-collection/collections.json \
  http://resource-catalogue.eoepca.local/stac/collections/metadata:main/items
```{{exec}}

Add both items and print each returned status:

```bash
jq -c '.[]' collections/datacube-ready-collection/items.json \
  | while read -r item; do
      id=$(jq -r '.id' <<<"${item}")
      code=$(curl -sS -o /dev/null -w '%{http_code}' \
        -X POST \
        -H 'Content-Type: application/json' \
        -d "${item}" \
        http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-datacube/items)
      echo "${id}: HTTP ${code}"
    done
```{{exec}}

The creation requests should return HTTP `201`. Verify what was stored:

```bash
curl -fsS http://resource-catalogue.eoepca.local/stac/collections \
  | jq '.collections[].id'

curl -fsS \
  http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-datacube/items \
  | jq '.features[].id'
```{{exec}}
