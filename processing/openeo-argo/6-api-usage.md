## Explore the OpenEO API

Save the workshop endpoint and demo credentials:

```bash
export OPENEO_URL=http://openeo.eoepca.local
export OPENEO_USER=eoepcauser
export OPENEO_PASSWORD=eoepcapass
```{{exec}}

Inspect the API capabilities:

```bash
curl -fsS -u "${OPENEO_USER}:${OPENEO_PASSWORD}" "${OPENEO_URL}/" \
  | jq '{
      title,
      api_version,
      backend_version,
      endpoint_count: (.endpoints | length)
    }'
```{{exec}}

List the collections exposed through OpenEO:

```bash
curl -fsS -u "${OPENEO_USER}:${OPENEO_PASSWORD}" \
  "${OPENEO_URL}/collections" \
  | jq '.collections[].id'
```{{exec}}

Inspect the datacube variables in the collection we ingested:

```bash
curl -fsS -u "${OPENEO_USER}:${OPENEO_PASSWORD}" \
  "${OPENEO_URL}/collections/sentinel-2-datacube" \
  | jq '{
      id,
      title,
      variables: (.["cube:variables"] | keys)
    }'
```{{exec}}

Finally, summarize the available processes:

```bash
curl -fsS -u "${OPENEO_USER}:${OPENEO_PASSWORD}" \
  "${OPENEO_URL}/processes" \
  | jq '{
      count: (.processes | length),
      examples: [.processes[0:10][].id]
    }'
```{{exec}}

These are the same discovery endpoints used by OpenEO clients to build and validate process graphs.
