#!/bin/bash
# Prepare the services used by the Datacube Access notebook.
set -euo pipefail

log() { echo "=== $* ==="; }
export KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"

log "Waiting for IAM and Crossplane"
kubectl wait --for=condition=Healthy providers.pkg.crossplane.io --all --timeout=10m
curl --fail --silent --show-error --retry 120 --retry-delay 5 --retry-all-errors \
  --max-time 10 --retry-max-time 600 \
  http://auth.eoepca.local/realms/eoepca/.well-known/openid-configuration >/dev/null
kubectl wait --for=condition=Established \
  crd/clientoptionalscopes.openidclient.keycloak.m.crossplane.io --timeout=5m

# CSI-rclone requires shared mount propagation inside Localcoda.
mount --make-rshared /

if [[ ! -d ~/deployment-guide ]]; then
  log "Cloning the deployment guide (release-2.1)"
  git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git ~/deployment-guide
fi

apt-get update -y
apt-get install -y gettext-base python3-venv

# Preconfigure the workshop choices; keep credentials supplied by the prerequisites.
cat <<'STATE' >> ~/.eoepca/state
export PERSISTENT_STORAGECLASS="local-path"
export USE_CERT_MANAGER="no"
export WORKSPACE_PIPELINE_CLIENT_ID="workspace-pipeline"
export WORKSPACE_API_CLIENT_ID="workspace-api"
export OIDC_WORKSPACE_ENABLED="true"
export USE_EXTERNAL_POSTGRES="no"
export POSTGRES_REPLICAS="1"
export POSTGRES_STORAGE_SIZE="1Gi"
export DATA_ACCESS_ENABLE_IAM="yes"
export EOAPI_CLIENT_ID="eoapi"
export ENABLE_TRANSACTIONS="yes"
export ENABLE_EOAPI_NOTIFIER="no"
export ENABLE_GEOPARQUET_EXPORT="no"
STATE
export EOAPI_PUBLIC_HOST="$(sed 's/PORT/82/; s|^http://||' /etc/killercoda/host)"

log "Deploying Workspace"
(
  cd ~/deployment-guide/scripts/workspace
  bash check-prerequisites.sh </dev/null
  bash configure-workspace.sh </dev/null
)

(
  cd ~/deployment-guide/scripts/workspace
  bash apply-secrets.sh

  helm upgrade -i workspace-dependencies-csi-rclone \
    oci://ghcr.io/eoepca/workspace/workspace-dependencies-csi-rclone \
    --version 2.2.0 --namespace workspace

  helm upgrade -i workspace-dependencies-educates \
    oci://ghcr.io/eoepca/workspace/workspace-dependencies-educates \
    --version 2.2.0 --namespace workspace \
    --values workspace-dependencies/educates-values.yaml

  kubectl apply -f workspace-dependencies/kyverno-registry-ingress-class.yaml

  helm repo add eoepca https://eoepca.github.io/helm-charts
  helm repo update eoepca
  helm upgrade -i workspace-api eoepca/rm-workspace-api \
    --version 2.2.2 --namespace workspace \
    --values workspace-api/generated-values.yaml

  helm upgrade -i workspace-pipeline \
    oci://ghcr.io/eoepca/workspace/workspace-pipeline \
    --version 2.2.0 --namespace workspace \
    --values workspace-pipeline/generated-values.yaml

  kubectl apply -f workspace-cleanup/datalab-cleaner.yaml
  kubectl apply -f workspace-dependencies/provider-configs.yaml

  source ~/.eoepca/state
  # Use the local ingress for server-to-server administration.
  KEYCLOAK_ADMIN_TOKEN=$(curl -X POST "http://auth.eoepca.local/realms/master/protocol/openid-connect/token" \
    --fail --silent --show-error -d "client_id=admin-cli" -d "grant_type=password" \
    -d "username=${KEYCLOAK_ADMIN_USER}" --data-urlencode "password=${KEYCLOAK_ADMIN_PASSWORD}" \
    | jq -er ".access_token")
  REALM_MANAGEMENT_CLIENT_UUID=$(curl --fail --silent --show-error -H "Authorization: Bearer ${KEYCLOAK_ADMIN_TOKEN}" \
    "http://auth.eoepca.local/admin/realms/${REALM}/clients?clientId=realm-management" | jq -er ".[0].id")
  export REALM_MANAGEMENT_CLIENT_UUID

  OFFLINE_ACCESS_ROLE=$(curl --fail --silent --show-error -H "Authorization: Bearer ${KEYCLOAK_ADMIN_TOKEN}" \
    "http://auth.eoepca.local/admin/realms/${REALM}/roles/offline_access")
  for TEST_USERNAME in "${KEYCLOAK_TEST_USER}" "${KEYCLOAK_TEST_ADMIN}"; do
    TEST_USER_ID=$(curl --fail --silent --show-error -H "Authorization: Bearer ${KEYCLOAK_ADMIN_TOKEN}" \
      "http://auth.eoepca.local/admin/realms/${REALM}/users?username=${TEST_USERNAME}&exact=true" | jq -er ".[0].id")
    curl --fail --silent --show-error -X POST -H "Authorization: Bearer ${KEYCLOAK_ADMIN_TOKEN}" -H "Content-Type: application/json" \
      "http://auth.eoepca.local/admin/realms/${REALM}/users/${TEST_USER_ID}/role-mappings/realm" \
      -d "[${OFFLINE_ACCESS_ROLE}]"
  done

  gomplate -f workspace-dependencies/pipeline-iam-template.yaml -o workspace-dependencies/generated-pipeline-iam.yaml
  kubectl apply -f workspace-dependencies/generated-pipeline-iam.yaml

  if ! kubectl get secret workspace-tls -n workspace >/dev/null 2>&1; then
    openssl req -x509 -newkey rsa:2048 -nodes -days 365 \
      -keyout /tmp/workspace-tls.key -out /tmp/workspace-tls.crt \
      -subj "/CN=*.${INGRESS_HOST}" -addext "subjectAltName=DNS:*.${INGRESS_HOST}"
    kubectl create secret tls workspace-tls -n workspace \
      --cert=/tmp/workspace-tls.crt --key=/tmp/workspace-tls.key
    rm /tmp/workspace-tls.key /tmp/workspace-tls.crt
  fi

  kubectl apply -f workspace-api/generated-iam.yaml
  kubectl apply -f workspace-api/generated-ingress.yaml

  helm upgrade kyverno kyverno/kyverno --version 3.8.2 --namespace kyverno --reuse-values \
    --set backgroundController.enabled=true --set reportsController.enabled=true \
    --wait --timeout=3m
  kubectl apply -f workspace-dependencies/kyverno-rbac-apisixpluginconfig.yaml
  kubectl apply -f workspace-dependencies/generated-workspace-session-iam-policy.yaml
)

log "Deploying Data Access (IAM-protected)"
(
  cd ~/deployment-guide/scripts/data-access
  bash check-prerequisites.sh </dev/null
  bash configure-data-access.sh </dev/null
)

(
  cd ~/deployment-guide/scripts/data-access
  bash apply-secrets.sh

  helm upgrade --install pgo oci://registry.developers.crunchydata.com/crunchydata/pgo \
    --version 5.8.8 --namespace data-access --create-namespace \
    --values postgres/generated-values.yaml --wait

  helm repo add eoapi https://developmentseed.org/eoapi-k8s/
  helm repo update eoapi
  helm upgrade -i eoapi eoapi/eoapi \
    --version 0.13.1 --namespace data-access --create-namespace \
    --values eoapi/generated-values.yaml \
    --set stac.autoscaling.enabled=false \
    --set-string browser.catalogUrl="http://${EOAPI_PUBLIC_HOST}/stac" \
    --set-string browser.authConfig.oidcConfig.redirect_uri="http://${EOAPI_PUBLIC_HOST}/browser/auth" \
    --timeout 10m

  helm repo add stac-manager https://stac-manager.ds.io/
  helm repo update stac-manager
  helm upgrade -i stac-manager stac-manager/stac-manager \
    --version 1.0.3 --namespace data-access \
    --values stac-manager/generated-values.yaml

  source ~/.eoepca/state
  kubectl apply -f iam/generated-iam.yaml
  kubectl apply -f eoapi/generated-ingress.yaml

  cat <<EOF | kubectl apply -f -
apiVersion: group.keycloak.m.crossplane.io/v1alpha1
kind: Memberships
metadata:
  name: data-access-admin-members
  namespace: iam-management
spec:
  providerConfigRef:
    name: keycloak-provider-config
    kind: ProviderConfig
  forProvider:
    realmId: ${REALM}
    groupIdRef:
      name: data-access-admin
      policy:
        resolution: Required
    members:
      - ${KEYCLOAK_TEST_ADMIN}
EOF
)

log "Waiting for Data Access pods (image pulls + DB init can take several minutes)"
kubectl wait --for=condition=Available deployment --all -n data-access --timeout=10m
kubectl wait --for=jsonpath='{.status.readyReplicas}'=1 statefulset \
  --selector postgres-operator.crunchydata.com/cluster=eoapi -n data-access --timeout=5m

log "Waiting for Workspace"
kubectl wait --for=condition=Available deployment --all -n workspace --timeout=10m
kubectl rollout status daemonset/csi-rclone-nodeplugin -n workspace --timeout=5m
kubectl rollout status statefulset/csi-rclone-controller -n workspace --timeout=5m

log "Waiting for API clients and permissions"
kubectl wait --for=condition=Ready -n iam-management \
  clients.openidclient.keycloak.m.crossplane.io/workspace-api \
  clients.openidclient.keycloak.m.crossplane.io/eoapi \
  memberships.group.keycloak.m.crossplane.io/workspace-admin-members \
  memberships.group.keycloak.m.crossplane.io/data-access-admin-members \
  roles.group.keycloak.m.crossplane.io/workspace-admin \
  roles.group.keycloak.m.crossplane.io/data-access-admin --timeout=5m
curl --fail --silent --show-error --retry 30 --retry-delay 2 --retry-all-errors \
  --max-time 10 --retry-max-time 120 http://eoapi.eoepca.local/stac/ >/dev/null

log "Preparing the notebook Python environment"
python3 -m venv ~/datacube-venv
~/datacube-venv/bin/pip install -r /tmp/assets/notebook-requirements.txt

log "Environment ready: IAM, Workspace and Data Access are deployed."
