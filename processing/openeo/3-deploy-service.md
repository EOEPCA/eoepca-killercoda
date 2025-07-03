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
  labels:
    app: openeo-geopyspark-driver
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
        # Using the same image but running it as a simple web service
        image: eoepca/openeo-geotrellis-kube:2.0-beta2
        imagePullPolicy: IfNotPresent
        # The command to start the lightweight web service
        command: ["/opt/openeo/bin/gunicorn", "--bind=0.0.0.0:8080", "--workers=1", "openeogeotrellis.deploy.local_web_service:app"]
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
bash configure-openeo.sh <<EOF
eoepca.local
local-path
no
EOF

# Modify the generated ingress to point to our new service
sed -i 's/name: openeo-geotrellis-openeo/name: openeo-service/' openeo-geotrellis/generated-ingress.yaml
sed -i 's/number: 50001/number: 80/' openeo-geotrellis/generated-ingress.yaml
sed -i 's/namespace: openeo-geotrellis/namespace: openeo/' openeo-geotrellis/generated-ingress.yaml

# Apply the modified ingress
kubectl apply -f openeo-geotrellis/generated-ingress.yaml -n openeo
```{{exec}}

This deploys the service and makes it accessible at `http://openeo.eoepca.local`.