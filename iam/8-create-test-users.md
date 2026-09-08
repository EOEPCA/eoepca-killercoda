## Crossplane

Crossplane is a Kubernetes add-on that enables the management of cloud infrastructure and services using Kubernetes-native APIs.

The Crossplane deployment comprises a core system deployment, which is then extended via the installation of Providers. Each Provider enables the management of a specific type of infrastructure or service, such as Kubernetes clusters, cloud storage, databases, etc.

One such provider is the Keycloak Provider, which allows for the management of Keycloak resources such as Realms, Clients, and Users using Kubernetes manifests.

The Crossplane core was already deployed as a prerequisite to this tutorial - with additional providers including the Keycloak Provider...

```bash
kubectl -n crossplane-system get pod
```{{exec}}

The Crossplane Keycloak Provider has been set up by the Helm Chart to be able to manage the Keycloak service. This includes managing OIDC clients, roles, groups, and users. Here we use it to add a test user.

## Adding a User via Crossplane

The realm import created the admin user `eoepcaadmin`{{}}. The plain test user is created afterwards via Crossplane, the same way other Building Blocks manage their own Keycloak resources.

The `configure-iam.sh`{{}} script rendered the `User`{{}} custom resource from the values you provided, and `apply-secrets.sh`{{}} created the `eoepca-user`{{}} secret that holds its initial password.

```bash
cat generated-eoepca-user.yaml
```{{exec}}

Apply it and wait for Crossplane to create the user in Keycloak:

```bash
kubectl apply -f generated-eoepca-user.yaml
kubectl wait --for=condition=Ready user.user.keycloak.m.crossplane.io/eoepca-user -n iam-management --timeout=2m
```{{exec}}

The `SYNCED`{{}} and `READY`{{}} columns show that Crossplane has reconciled the resource, and `EXTERNAL-NAME`{{}} is the ID that Keycloak assigned to the user.

```bash
kubectl get user.user.keycloak.m.crossplane.io -n iam-management
```{{exec}}

## Verify the Users

Ask Keycloak itself which users now exist in the realm - using the Keycloak Admin API.

```bash
source ~/.eoepca/state
ADMIN_TOKEN=$( \
  curl --silent --show-error \
    -X POST \
    -d "username=${KEYCLOAK_ADMIN_USER}" \
    --data-urlencode "password=${KEYCLOAK_ADMIN_PASSWORD}" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" \
    "http://auth.eoepca.local/realms/master/protocol/openid-connect/token" | jq -r '.access_token' \
)
curl --silent --show-error \
  -H "Authorization: Bearer ${ADMIN_TOKEN}" \
  "http://auth.eoepca.local/admin/realms/eoepca/users" | jq '.[] | {username, email, emailVerified}'
```{{exec}}

Both `eoepcaadmin`{{}} (from the realm import) and `eoepcauser`{{}} (from the Crossplane `User`{{}}) are listed.

The same users can be seen in the [Keycloak Admin Console]({{TRAFFIC_HOST1_90}}/admin/master/console/#/eoepca/users) - using the `admin`{{}} credentials defined in the `~/.eoepca/state`{{}} file.

```bash
grep KEYCLOAK_ADMIN_ ~/.eoepca/state
```{{exec}}
