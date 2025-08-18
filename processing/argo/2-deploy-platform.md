Now we'll deploy the entire platform using the GeoLabs feature branch that includes Argo Workflows integration.

First, clone and prepare the repository with necessary fixes:

```bash
git clone https://github.com/GeoLabs/charts.git geolabs-charts
cd geolabs-charts
git checkout feature/argo-integration
cd zoo-project-dru

# Fix the template bug 
sed -i 's/value: {{ \.Values\.workflow\.argo\.defaultMaxCores | toString }}/value: "{{ .Values.workflow.argo.defaultMaxCores }}"/g' templates/dp-zoofpm.yaml
```{{exec}}

Create a values file configured for Killercoda environment:

```bash
cat <<EOF > values-killercoda.yaml
persistence:
  storageClass: standard
  procServicesStorageClass: standard
  tmpStorageClass: standard

workflow:
  storageClass: standard
  defaultMaxRam: "2Gi"
  defaultMaxCores: 2
  argo:
    enabled: true
    storageClass: standard
    defaultVolumeSize: "2Gi"
    defaultMaxRam: "2Gi"
    defaultMaxCores: 2
    wfNamespace: ns1
    wfServer: "http://argo-server.ns1.svc.cluster.local:2746"
    wfToken: ""
    wfSynchronizationCm: "semaphore-argo-cwl-runner-stage-in-out"
    CwlRunnerTemplare: "argo-cwl-runner-stage-in-out"
    CwlRunnerTemplate: "argo-cwl-runner-stage-in-out"
    CwlRunnerEndpoint: "calrissian-runner"
    autoTokenManagement: true

minio:
  enabled: true
  auth:
    rootUser: minio-admin
    rootPassword: minio-secret-password
  persistence:
    enabled: true
    storageClass: standard
    size: 5Gi
  defaultBuckets: "eoepca results"
  fullnameOverride: "s3-service"

postgresql:
  enabled: true
  auth:
    database: zoo
    username: zoo
    password: zoo-password

redis:
  enabled: true

cookiecutter:
  templateUrl: https://github.com/gfenoy/zoo-argo-wf-proc-service-template.git
  templateBranch: feature/additional-parameters-log-urls

iam:
  enabled: false

monitoring:
  enabled: false

argo-workflows:
  enabled: true
  global:
    namespace: ns1
  monitoring:
    enabled: false
  minio:
    enabled: false
    external:
      enabled: true
      serviceName: "s3-service"
      port: 9000
      secure: false
      accessKeySecret:
        name: "s3-service"
        key: "root-user"
      secretKeySecret:
        name: "s3-service"
        key: "root-password"
  controller:
    instanceID: zoo
  stageInOut:
    enabled: true
EOF
```{{exec}}

Deploy the platform:

```bash
# Update dependencies and install
helm dependency update
helm dependency build .
helm upgrade -i zoo-project-dru . \
  --namespace ns1 \
  -f values-killercoda.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=zoo-project-dru -n ns1 --timeout=120s
kubectl wait --for=condition=ready pod -l app=argo-server -n ns1 --timeout=120s
```{{exec}}

Now we need to disable JWT authentication to allow unauthenticated access. (This is for demonstration purposes only; in production, you should enable JWT authentication.)

```bash
# Disable JWT in the ConfigMap
kubectl get configmap zoo-project-dru-zoo-project-config -n ns1 -o yaml > zoo-config.yaml
sed -i 's/has_jwt_service=true/has_jwt_service=false/g' zoo-config.yaml
kubectl apply -f zoo-config.yaml

# Restart the pod to apply changes
kubectl delete pod -l app.kubernetes.io/name=zoo-project-dru -n ns1
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=zoo-project-dru -n ns1 --timeout=120s
```{{exec}}

# Fix issue with env variables in the deployment
```bash
kubectl set env deployment/zoo-project-dru-zoofpm \
  ARGO_CWL_RUNNER_TEMPLATE=argo-cwl-runner-stage-in-out \
  ARGO_CWL_RUNNER_ENTRYPOINT=calrissian-runner \
  -n ns1
```{{exec}}

# Fix issue with workflow template
```bash
kubectl get workflowtemplate argo-cwl-runner-stage-in-out -n ns1 -o yaml | \
  sed 's/s3-service\.zoo\.svc\.cluster\.local/s3-service.ns1.svc.cluster.local/g' | \
  kubectl apply -f -
```{{exec}}


# Even more fixes
```bash
# Fix the feature-collection template to include http:// prefix
kubectl get workflowtemplate argo-cwl-runner-stage-in-out -n ns1 -o yaml | \
  sed 's|endpoint_url="s3-service.ns1.svc.cluster.local:9000"|endpoint_url="http://s3-service.ns1.svc.cluster.local:9000"|g' | \
  kubectl apply -f -
```{{exec}}

# Fix workflow controller artifact repository config
```bash
kubectl get configmap workflow-controller-configmap -n ns1 -o yaml | \
  sed 's/s3-service\.zoo\.svc\.cluster\.local/s3-service.ns1.svc.cluster.local/g' | \
  kubectl apply -f -
```{{exec}}

# Fix minio password
```bash
# Update the feature-collection template with the correct password
kubectl get workflowtemplate argo-cwl-runner-stage-in-out -n ns1 -o yaml | \
  sed 's/aws_secret_access_key="minio-admin"/aws_secret_access_key="minio-secret-password"/g' | \
  kubectl apply -f -
```{{exec}}

