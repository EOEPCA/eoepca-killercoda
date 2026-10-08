We can now deploy the Workspace building block.

## Kubernetes Secrets

Kubernetes secrets are used to share the credentials that the Workspace services rely upon.

```bash
bash apply-secrets.sh
```{{exec}}

## Workspace Dependencies

The workspace dependencies include CSI-RClone for storage mounting and the Educates framework for workspace environments.

```bash
# Educates and the session ingress policies require Kyverno.
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update kyverno
helm upgrade -i kyverno kyverno/kyverno \
  --version 3.7.2 \
  --namespace kyverno \
  --create-namespace \
  --set backgroundController.enabled=true \
  --wait --timeout=5m

# Deploy CSI-RClone
helm upgrade -i workspace-dependencies-csi-rclone \
  oci://ghcr.io/eoepca/workspace/workspace-dependencies-csi-rclone \
  --version 2.2.1 \
  --namespace workspace

# Deploy Educates
helm upgrade -i workspace-dependencies-educates \
  oci://ghcr.io/eoepca/workspace/workspace-dependencies-educates \
  --version 2.2.1 \
  --namespace workspace \
  --values workspace-dependencies/educates-values.yaml
```{{exec}}

Educates does not set an `ingressClassName` on the per-session registry `Ingress`, so APISIX never routes it. Apply a Kyverno policy that sets it on every session:

```bash
kubectl apply -f workspace-dependencies/kyverno-registry-ingress-class.yaml
```{{exec}}

## Workspace API

The Workspace API provides a REST interface for administration of workspaces.

```bash
helm repo add eoepca https://eoepca.github.io/helm-charts
helm repo update eoepca
helm upgrade -i workspace-api eoepca/rm-workspace-api \
  --version 2.2.2 \
  --namespace workspace \
  --values workspace-api/generated-values.yaml
```{{exec}}

## Workspace Pipeline

The Workspace Pipeline manages the templating and provisioning of resources within newly created workspaces.

```bash
helm upgrade -i workspace-pipeline \
  oci://ghcr.io/eoepca/workspace/workspace-pipeline \
  --version 2.2.1 \
  --namespace workspace \
  --values workspace-pipeline/generated-values.yaml
```{{exec}}

## DataLab Session Cleaner

This deploys a CronJob that stops all Datalab sessions daily at 20:00 UTC, including the default session. Their configuration is preserved so they can be started again.

```bash
kubectl apply -f workspace-cleanup/datalab-cleaner.yaml
```{{exec}}

## Crossplane Provider Configurations

Each Crossplane provider used by the Workspace BB needs a `ProviderConfig` in the `workspace` namespace. The MinIO provider already has one, configured cluster-wide in the prerequisites.


```bash
kubectl apply -f workspace-dependencies/provider-configs.yaml
```{{exec}}

## Keycloak Client for Workspace Pipeline

The workspace pipeline needs its own Keycloak client, `workspace-pipeline`, so it can self-serve a Keycloak client/roles/groups for every workspace it provisions.

Render and apply the `workspace-pipeline` client and grant it the roles it needs on Keycloak's built-in `realm-management` client: `manage-users`, `manage-authorization`, `manage-clients`, `create-client` and `realm-admin`.

```bash
source ~/.eoepca/state
gomplate -f workspace-dependencies/pipeline-iam-template.yaml -o workspace-dependencies/generated-pipeline-iam.yaml
kubectl apply -f workspace-dependencies/generated-pipeline-iam.yaml
```{{exec}}


## TLS Certificate for Datalab Sessions

Each Datalab session ingress references a `workspace-tls` secret in the `workspace` namespace. APISIX drops an ingress whose TLS secret is missing, so create it before the first workspace.

The deployment guide uses a cert-manager wildcard certificate. This tutorial is served over HTTP and has no public DNS, so a self-signed certificate is enough:

```bash
openssl req -x509 -newkey rsa:2048 -nodes -subj "/CN=*.eoepca.local" -keyout tls.key -out tls.crt
kubectl -n workspace create secret tls workspace-tls --cert=tls.crt --key=tls.key
```{{exec}}

## Keycloak Client for the Workspace API

Render and apply the `workspace-api` Keycloak client. Its protocol mappers add the `aud` and `groups` claims that the Workspace API requires in a token.

This also creates an `admin` client role, and a `workspace-admin` group holding it with `eoepcaadmin` as a member. Members of that group can manage every workspace, not only their own.

```bash
source ~/.eoepca/state
gomplate -f workspace-api/iam-template.yaml -o workspace-api/generated-iam.yaml
kubectl apply -f workspace-api/generated-iam.yaml
```{{exec}}

**_Workspace API Ingress_**

```bash
kubectl apply -f workspace-api/generated-ingress.yaml
```{{exec}}

## Protect Datalab Sessions with Keycloak SSO

The Kyverno policy adds Keycloak login and the IAM OPA policy `eoepca/workspace/wsui` to each Datalab session ingress. The policy checks the user's workspace access or administrator role.

Grant Kyverno permission to manage `ApisixPluginConfig` resources, then apply the session-protection policy:

```bash
kubectl apply -f workspace-dependencies/kyverno-rbac-apisixpluginconfig.yaml
kubectl apply -f workspace-dependencies/generated-workspace-session-iam-policy.yaml
```{{exec}}


This completes the deployment of the Workspace building block.
