## Deploying the openEO Service

Instead of a full Spark cluster, we will deploy the openEO GeoPySpark driver as a lightweight, standalone service. This is much better suited for a resource-constrained environment.

First, create a namespace for our service.
```bash
kubectl create namespace openeo
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
  namespace: openeo-geotrellis
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/enable-cors: "true"
spec:
  ingressClassName: nginx
  rules:
    - host: openeo.eoepca.local
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