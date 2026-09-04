#!/bin/bash
# Deploys IAM, Workspace and Data Access into this scenario's own cluster - the live-tutorial
# counterpart to build-image.sh. Datacube Access itself is a metadata convention, not a service
# (see README.md) - the notebook is what exercises it, nothing to deploy here for it.
set -euo pipefail

log() { echo "=== $* ==="; }

if [[ ! -d ~/deployment-guide ]]; then
  log "Cloning the deployment guide (release-2.1)"
  git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git ~/deployment-guide
fi

apt-get update -y && apt-get install -y gettext-base

log "Deploying Workspace"
(
  cd ~/deployment-guide/scripts/workspace
  bash check-prerequisites.sh
  bash configure-workspace.sh
) <<'ANSWERS'
n
local-path
no
no
no
no
no
workspace-pipeline
workspace-api
true
no
no
no
ANSWERS

(
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
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
  # KEYCLOAK_HOST is the external browser-facing URL (for the OIDC issuer) - use the internal
  # auth.eoepca.local address here instead, since this is a server-to-server call and the
  # external URL hairpins back through the killercoda proxy unreliably (502s from inside itself)
  KEYCLOAK_ADMIN_TOKEN=$(curl -X POST "http://auth.eoepca.local/realms/master/protocol/openid-connect/token" \
    --silent --show-error -d "client_id=admin-cli" -d "grant_type=password" \
    -d "username=${KEYCLOAK_ADMIN_USER}" --data-urlencode "password=${KEYCLOAK_ADMIN_PASSWORD}" \
    | jq -r ".access_token")
  export REALM_MANAGEMENT_CLIENT_UUID=$(curl --silent --show-error -H "Authorization: Bearer ${KEYCLOAK_ADMIN_TOKEN}" \
    "http://auth.eoepca.local/admin/realms/${REALM}/clients?clientId=realm-management" | jq -r ".[0].id")

  OFFLINE_ACCESS_ROLE=$(curl --silent --show-error -H "Authorization: Bearer ${KEYCLOAK_ADMIN_TOKEN}" \
    "http://auth.eoepca.local/admin/realms/${REALM}/roles/offline_access")
  for TEST_USERNAME in "${KEYCLOAK_TEST_USER}" "${KEYCLOAK_TEST_ADMIN}"; do
    TEST_USER_ID=$(curl --silent --show-error -H "Authorization: Bearer ${KEYCLOAK_ADMIN_TOKEN}" \
      "http://auth.eoepca.local/admin/realms/${REALM}/users?username=${TEST_USERNAME}&exact=true" | jq -r ".[0].id")
    curl --silent --show-error -X POST -H "Authorization: Bearer ${KEYCLOAK_ADMIN_TOKEN}" -H "Content-Type: application/json" \
      "http://auth.eoepca.local/admin/realms/${REALM}/users/${TEST_USER_ID}/role-mappings/realm" \
      -d "[${OFFLINE_ACCESS_ROLE}]"
  done

  gomplate -f workspace-dependencies/pipeline-iam-template.yaml -o workspace-dependencies/generated-pipeline-iam.yaml
  kubectl apply -f workspace-dependencies/generated-pipeline-iam.yaml

  kubectl apply -f workspace-api/generated-iam.yaml
  kubectl apply -f workspace-api/generated-ingress.yaml

  helm upgrade kyverno kyverno/kyverno --version 3.8.2 --namespace kyverno --reuse-values \
    --set backgroundController.enabled=true --set reportsController.enabled=true \
    --wait --timeout=3m
  kubectl apply -f workspace-dependencies/kyverno-rbac-apisixpluginconfig.yaml
  kubectl apply -f workspace-dependencies/generated-workspace-session-iam-policy.yaml
)

log "Waiting for Workspace pods"
# csi-rclone-nodeplugin CrashLoopBackOffs here by design (nested runtime) - deployments only, not pod --all
kubectl wait --for=condition=Available deployment --all -n workspace --timeout=5m

log "Deploying Data Access (IAM-protected)"
(
  cd ~/deployment-guide/scripts/data-access
  bash check-prerequisites.sh
  bash configure-data-access.sh
) <<'ANSWERS'
no
no
no
no
1
1Gi
yes
n
n
eoapi
yes
no
no
ANSWERS

(
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  cd ~/deployment-guide/scripts/data-access
  bash apply-secrets.sh

  helm upgrade --install pgo oci://registry.developers.crunchydata.com/crunchydata/pgo \
    --version 5.8.8 --namespace data-access --create-namespace \
    --values postgres/generated-values.yaml --wait

  helm repo add eoapi https://developmentseed.org/eoapi-k8s/
  helm repo update eoapi
  helm upgrade -i eoapi eoapi/eoapi \
    --version 0.13.1 --namespace data-access --create-namespace \
    --values eoapi/generated-values.yaml --set stac.autoscaling.minReplicas=1 --timeout 10m

  helm repo add stac-manager https://stac-manager.ds.io/
  helm repo update stac-manager
  helm upgrade -i stac-manager stac-manager/stac-manager \
    --version 1.0.3 --namespace data-access \
    --values stac-manager/generated-values.yaml --set service.port=8080

  source ~/.eoepca/state
  # missing ClientOptionalScopes CRD in this Crossplane Keycloak provider version - see README.md
  kubectl apply -f iam/generated-iam.yaml || true
  # no cert-manager here, so the Certificate resource always fails - ApisixRoute/ApisixTls still apply
  kubectl apply -f eoapi/generated-ingress.yaml || true

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

# titiler-openeo skipped: ghcr.io/sentinel-hub/titiler-openeo broken on all tags since 2026-08-23, only affects /openeo/

log "Loading the sample datacube-ready STAC collection"
# not deployment-guide's own collections/ingest.sh - see README.md for why
(
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  cd ~/deployment-guide/scripts/datacube-access/collections/datacube-ready-collection
  RASTER_POD=$(kubectl get pod -n data-access -l app=eoapi-raster -o jsonpath="{.items[0].metadata.name}")
  DSN=$(kubectl exec -n data-access "$RASTER_POD" -c raster -- printenv PGADMIN_URI)
  kubectl run pgstac-loader -n data-access --image=ghcr.io/stac-utils/pgstac-pypgstac:v0.10.0 \
    --restart=Never --command -- sleep 300
  kubectl wait -n data-access --for=condition=Ready pod/pgstac-loader --timeout=2m
  kubectl cp collections.json data-access/pgstac-loader:/tmp/collections.json
  kubectl cp items.json data-access/pgstac-loader:/tmp/items.json
  kubectl exec -n data-access pgstac-loader -- pypgstac load collections /tmp/collections.json --dsn "$DSN" --method insert_ignore
  kubectl exec -n data-access pgstac-loader -- pypgstac load items /tmp/items.json --dsn "$DSN" --method insert_ignore
  kubectl delete pod pgstac-loader -n data-access --wait=false
)

log "Final readiness check"
kubectl wait --for=condition=Available deployment --all --all-namespaces --timeout=5m

log "Environment ready: IAM, Workspace and Data Access are deployed."
