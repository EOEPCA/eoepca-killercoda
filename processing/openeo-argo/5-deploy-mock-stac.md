
## Deploy Mock STAC Catalogue

The OpenEO executor requires a STAC catalogue to query for data. We'll deploy a minimal mock STAC service for testing.

```bash
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: mock-stac-config
  namespace: openeo
data:
  stac.json: |
    {
      "type": "Catalog",
      "id": "mock-stac",
      "stac_version": "1.0.0",
      "description": "Mock STAC for testing",
      "links": [
        {"rel": "self", "href": "/stac", "type": "application/json"},
        {"rel": "root", "href": "/stac", "type": "application/json"},
        {"rel": "child", "href": "/stac/collections/test", "type": "application/json"}
      ]
    }
  collection.json: |
    {
      "type": "Collection",
      "id": "test",
      "stac_version": "1.0.0",
      "description": "Test collection",
      "license": "public-domain",
      "extent": {
        "spatial": {"bbox": [[11.4, 46.5, 11.5, 46.6]]},
        "temporal": {"interval": [["2024-01-01T00:00:00Z", "2024-12-31T23:59:59Z"]]}
      },
      "links": [
        {"rel": "self", "href": "/stac/collections/test"},
        {"rel": "root", "href": "/stac"},
        {"rel": "items", "href": "/stac/collections/test/items"}
      ]
    }
  items.json: |
    {
      "type": "FeatureCollection",
      "features": []
    }
  nginx.conf: |
    events { worker_connections 128; }
    http {
      server {
        listen 80;
        location /stac { default_type application/json; alias /data/stac.json; }
        location /stac/ { default_type application/json; alias /data/stac.json; }
        location /stac/collections/test { default_type application/json; alias /data/collection.json; }
        location /stac/collections/test/items { default_type application/json; alias /data/items.json; }
        location /stac/collections { 
          default_type application/json; 
          return 200 '{"collections":[{"id":"test","title":"Test","description":"Test collection","extent":{"spatial":{"bbox":[[11.4,46.5,11.5,46.6]]},"temporal":{"interval":[["2024-01-01T00:00:00Z","2024-12-31T23:59:59Z"]]}}}]}';
        }
      }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mock-stac
  namespace: openeo
spec:
  replicas: 1
  selector:
    matchLabels: {app: mock-stac}
  template:
    metadata:
      labels: {app: mock-stac}
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports: [{containerPort: 80}]
        volumeMounts:
        - {name: config, mountPath: /etc/nginx/nginx.conf, subPath: nginx.conf}
        - {name: config, mountPath: /data/stac.json, subPath: stac.json}
        - {name: config, mountPath: /data/collection.json, subPath: collection.json}
        - {name: config, mountPath: /data/items.json, subPath: items.json}
      volumes:
      - name: config
        configMap: {name: mock-stac-config}
---
apiVersion: v1
kind: Service
metadata:
  name: stac
  namespace: openeo
spec:
  selector: {app: mock-stac}
  ports: [{port: 80, targetPort: 80}]
EOF
```{{exec}}

Add DNS entry for the STAC service:

```bash
echo "$(kubectl get svc stac -n openeo -o jsonpath='{.spec.clusterIP}') stac.eoepca.local" >> /etc/hosts
```{{exec}}

Wait for deployment and test:

```bash
kubectl rollout status deployment mock-stac -n openeo
curl -s http://stac.eoepca.local/stac | jq .
curl -s http://stac.eoepca.local/stac/collections | jq .
```{{exec}}