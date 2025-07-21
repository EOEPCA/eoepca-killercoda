## Deploying the openEO Service

Instead of a full Spark cluster, we will deploy the openEO GeoPySpark driver as a lightweight, standalone service. This is much better suited for a resource-constrained environment.

First, create a namespace for our service.
```bash
kubectl create namespace openeo
```{{exec}}

## backend config
```
cat <<EOF > custom_backend_config.py
from openeogeotrellis.config import GpsBackendConfig

config = GpsBackendConfig(
    id="geopyspark-local-basic-auth",
    oidc_providers=[],
    enable_basic_auth=True,
    valid_basic_auth=lambda user,
    password: user == "openeo" and password == "openeo",
    layer_catalog_files=["/etc/openeo/config/layercatalog.json"]
)
EOF
```{{exec}}





## layercatalog
```
cat <<EOF > layercatalog.json
[
  {
    "id": "TestCollection-LonLat4x4",
    "_vito": {
      "data_source": {
        "type": "testing"
      }
    },
    "cube:dimensions": {
      "x": {
        "type": "spatial",
        "axis": "x",
        "reference_system": {"$schema":"https://proj.org/schemas/v0.2/projjson.schema.json","type":"GeodeticCRS","name":"AUTO 42001 (Universal Transverse Mercator)","datum":{"type":"GeodeticReferenceFrame","name":"World Geodetic System 1984","ellipsoid":{"name":"WGS 84","semi_major_axis":6378137,"inverse_flattening":298.257223563}},"coordinate_system":{"subtype":"ellipsoidal","axis":[{"name":"Geodetic latitude","abbreviation":"Lat","direction":"north","unit":"degree"},{"name":"Geodetic longitude","abbreviation":"Lon","direction":"east","unit":"degree"}]},"area":"World","bbox":{"south_latitude":-90,"west_longitude":-180,"north_latitude":90,"east_longitude":180},"id":{"authority":"OGC","version":"1.3","code":"Auto42001"}}
      },
      "y": {
        "type": "spatial",
        "axis": "y",
        "reference_system": {"$schema":"https://proj.org/schemas/v0.2/projjson.schema.json","type":"GeodeticCRS","name":"AUTO 42001 (Universal Transverse Mercator)","datum":{"type":"GeodeticReferenceFrame","name":"World Geodetic System 1984","ellipsoid":{"name":"WGS 84","semi_major_axis":6378137,"inverse_flattening":298.257223563}},"coordinate_system":{"subtype":"ellipsoidal","axis":[{"name":"Geodetic latitude","abbreviation":"Lat","direction":"north","unit":"degree"},{"name":"Geodetic longitude","abbreviation":"Lon","direction":"east","unit":"degree"}]},"area":"World","bbox":{"south_latitude":-90,"west_longitude":-180,"north_latitude":90,"east_longitude":180},"id":{"authority":"OGC","version":"1.3","code":"Auto42001"}}
      },
      "t": {
        "type": "temporal"
      },
      "bands": {
        "type": "bands",
        "values": [
          "Flat:0",
          "Flat:1",
          "Flat:2",
          "TileCol",
          "TileRow",
          "TileColRow:10",
          "Longitude",
          "Latitude",
          "Year",
          "Month",
          "Day"
        ]
      }
    },
    "extent": {
      "spatial": {
        "bbox": [
          [
            -180,
            -56,
            180,
            83
          ]
        ]
      },
      "temporal": {
        "interval": [
          [
            "2000-01-01",
            null
          ]
        ]
      }
    }
  }
]
EOF
```{{exec}}


```bash
kubectl create configmap openeo-config -n openeo \
    --from-file=local_backend_config.py=./custom_backend_config.py \
    --from-file=layercatalog.json=./layercatalog.json
```{{exec}}

Now, create a YAML file for the `Deployment` and `Service`. This manifest defines a single pod running the openEO service and exposes it within the cluster on port 8080.

```bash
cat <<EOF > openeo-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openeo-geopyspark-driver
  namespace: openeo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: openeo-geopyspark-driver
  template:
    metadata:
      labels:
        app: openeo-geopyspark-driver
    spec:
      volumes:
        - name: config-volume
          configMap:
            name: openeo-config
      containers:
      - name: openeo
        image: vito-docker.artifactory.vgt.vito.be/openeo-base:latest
        imagePullPolicy: IfNotPresent
        env:
        - name: PYTHONPATH
          value: "/usr/local/spark/python/lib/py4j-0.10.9.7-src.zip:/usr/local/spark/python"
        - name: GEOPYSPARK_JARS_PATH
          value: "/opt"
        - name: OPENEO_LOCAL_DEBUGGING
          value: "false"
        - name: GDAL_PAM_ENABLED
          value: "NO"
        - name: FLASK_DEBUG
          value: "0"
        - name: OPENEO_DEV_GUNICORN_HOST
          value: "0.0.0.0"
        - name: OPENEO_BACKEND_CONFIG
          value: "/etc/openeo/config/local_backend_config.py"
        
        volumeMounts:
          - name: config-volume
            mountPath: /etc/openeo/config

        command: ["/opt/venv/bin/python3"]
        args:
          - "/opt/venv/bin/openeo_local.py"

        ports:
        - name: http
          containerPort: 8080
        resources:
          requests:
            cpu: "200m"
            memory: "1Gi"
          limits:
            cpu: "500m"
            memory: "2Gi"
---
apiVersion: v1
kind: Service
metadata:
  name: openeo-service
  namespace: openeo
spec:
  selector:
    app: openeo-geopyspark-driver
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
EOF
```{{exec}}

Apply the manifest to create the `Deployment` and `Service`:

```bash
kubectl apply -f openeo-deployment.yaml
```{{exec}}

Finally, deploy an Ingress to expose the service publicly. Note that the service port is now `80`.

```bash
cat <<EOF > openeo-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: oeo
  namespace: openeo
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/enable-cors: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: ${INGRESS_HOST}
      http:
        paths:
          - path: "/"
            pathType: Prefix
            backend:
              service:
                name: openeo-service
                port:
                  number: 80
EOF
```{{exec}}

```bash
kubectl apply -f openeo-ingress.yaml
```{{exec}}

This deploys the service and makes it accessible at `http://openeo.eoepca.local`.