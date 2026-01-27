The outcome of the harvesting is best visualised via [STAC Browser](https://github.com/radiantearth/stac-browser).

### **Simple Data Server**

We start a simple nginx server to offer the harvetsed data for retrieval via the asset URLs configured in the registered STAC items.

```
kubectl apply -f registration-harvester/generated-eodata-server.yaml
```{{exec}}

### **Deploy STAC Browser**

```bash
source ~/.eoepca/state

CATALOGUE_EXT_URL="$(
  sed "s#PORT#$(awk -v host="$INGRESS_HOST" '$0 ~ ("resource-catalogue." host) {print $1}' /tmp/assets/killercodaproxy)#" \
    /etc/killercoda/host
)"

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stac-browser
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stac-browser
  template:
    metadata:
      labels:
        app: stac-browser
    spec:
      containers:
        - name: stac-browser
          image: ghcr.io/radiantearth/stac-browser:latest
          ports:
            - containerPort: 8080
          env:
            - name: SB_catalogUrl
              value: "${CATALOGUE_EXT_URL}/stac"
            - name: SB_catalogTitle
              value: "EOEPCA Catalogue"
---
apiVersion: v1
kind: Service
metadata:
  name: stac-browser
spec:
  selector:
    app: stac-browser
  ports:
    - port: 8080
      targetPort: 8080
      protocol: TCP
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: stac-browser
spec:
  ingressClassName: apisix
  rules:
    - host: stac-browser.${INGRESS_HOST}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: stac-browser
                port:
                  number: 8080
EOF
```{{exec}}

### **Wait for Readiness**

```bash
kubectl rollout status -w deploy/stac-browser
```{{exec}}

### **Open STAC Browser**

Open the [STAC Browser Web UI]({{TRAFFIC_HOST1_85}}).

> The harvesting of the scenes can take some time (10+ minutes). Refresh the view in STAC Browser to see their ongoing registration.

Navigate through the [Landsat]({{TRAFFIC_HOST1_85}}/stac/collections/landsat-ot-c2-l2) and [Sentinel]({{TRAFFIC_HOST1_85}}/stac/collections/sentinel-2-c1-l2a) collections.

> The Sentinel jpeg2000 assets cannot be visualised by STAC Browser.
