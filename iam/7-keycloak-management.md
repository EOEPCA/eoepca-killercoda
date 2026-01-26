
## Crossplane

Crossplane is a Kubernetes add-on that enables the management of cloud infrastructure and services using Kubernetes-native APIs.

The Crossplane deployment comprises a core system deployment, which is then extended via the installation of Providers. Each Provider enables the management of a specific type of infrastructure or service, such as Kubernetes clusters, cloud storage, databases, etc.

One such provider is the Keycloak Provider, which allows for the management of Keycloak resources such as Realms, Clients, and Users using Kubernetes manifests.

The Crossplane core was already deployed as a prerequisite to this tutorial - with additional providers including the Keycloak Provider...

```bash
kubectl -n crossplane-system get pod
```{{exec}}

## IAM Management via Crossplane

Using the Crossplane Keycloak provider, we create a Keycloak client that allows Crossplane to manage Keycloak resources declaratively via CRDs. This is established via the following steps:
* Create a dedicated Keycloak client `iam-management`{{}} for Crossplane, with the necessary Realm Management roles (`manage-users`{{}}, `manage-clients`{{}}, `manage-authorization`{{}}, `create-client`{{}} )
* Create the namespace `iam-management`{{}} for Crossplane Keycloak resources
* Establish Crossplane Keycloak provider configuration to connect to Keycloak using the `iam-management`{{}} client - serving resources in the `iam-management`{{}} namespace

> This provides the framework through which to manage the `eoepca`{{}} realm and its clients, by creation of Crossplane Keycloak resources in the `iam-management`{{}} namespace that will be satisfied by the Crossplane Keycloak provider.

## Keycloak Client for Crossplane Provider

Create a Keycloak client for the Crossplane Keycloak provider to allow it to interface with Keycloak. We create the client `iam-management`{{}}, which is used to perform administrative actions against the Keycloak API.

Use the `create-client.sh`{{}} script in the `scripts/utils/`{{}} directory. This script prompts you for basic details and automatically creates a Keycloak client in your chosen realm.

Before running the script we will need the client secret that was previously generated:

```bash
grep IAM_MANAGEMENT_CLIENT_SECRET ~/.eoepca/state
```{{exec}}

The value of this secret will be used below.

```bash
bash ../utils/create-client.sh
```{{exec}}

When prompted, provide the following details:

> NOTE that some of the previosly answered questions are repeated - in which case the existing value can be accepted.

* `KEYCLOAK_ADMIN_USER`{{}} already set: `no`{{exec}}
* `KEYCLOAK_ADMIN_PASSWORD`{{}} already set: `no`{{exec}}
* `INGRESS_HOST`{{}} already set: `no`{{exec}}
* `KEYCLOAK_HOST`{{}} already set: `no`{{exec}}
* `REALM`{{}} already set: `no`{{exec}}
* Confidential client?: `true`{{exec}}
    A confidential client is able to maintain its client secret securely (e.g. a backend service)
* Client ID: `iam-management`{{exec}}
    The ID of the OIDC client to be used by the Identity API service
* Client Name: `IAM Management`{{exec}}
    Display name for the client
* Client Description: `Management of Keycloak resource via Crossplane`{{exec}}
    Description for the client
* Client Secret: **_Paste value from above_**
    The secret that, together with the Client ID, provides the client credentials
* Subdomain: `iam-management`{{exec}}
    The main redirect URL for OIDC flows - within the `INGRESS_HOST`{{}} domain
* Additional Subdomains: **_Leave blank_**
    Additional redirect URLs for OIDC flows - within the `INGRESS_HOST`{{}} domain
* Additional Hosts: **_Leave blank_**
    Additional redirect URLs for OIDC flows - external (outside the `INGRESS_HOST`{{}} domain)

After it completes, you should see a JSON snippet confirming the newly created client.

## Keycloak Client Roles

The `iam-management`{{}} client requires specific `realm-management`{{}} roles to perform administrative actions against Keycloak.

Run the `crossplane-client-roles.sh`{{}} script in the `scripts/utils/`{{}} directory, providing the `iam-management`{{}} client ID as an argument:

> This script uses the Keycloak API to assign the necessary roles to the specified client.

```bash
bash ../utils/crossplane-client-roles.sh iam-management
```{{exec}}

## Keycloak Provider Configuration

Now the Keycloak client is created, we can set up the Crossplane Keycloak provider configuration to connect to Keycloak using this client.

### **Create Namespace**

First, create a dedicated namespace for the Crossplane Keycloak resources:

```bash
kubectl create namespace iam-management
```{{exec}}

### **Client Credentials Secret**

Create a Kubernetes secret in the `iam-management`{{}} namespace to hold the Keycloak client credentials:

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: iam-management-client
  namespace: iam-management
stringData:
  credentials: |
    {
      "client_id": "$IAM_MANAGEMENT_CLIENT_ID",
      "client_secret": "$IAM_MANAGEMENT_CLIENT_SECRET",
      "url": "http://iam-keycloak.iam",
      "base_path": "",
      "realm": "$REALM"
    }
EOF
```{{exec}}

### **Keycloak Provider Configuration**

Configure the Crossplane Keycloak provider to use the created client credentials secret:

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: keycloak.m.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: provider-keycloak
  namespace: iam-management
spec:
  credentialsSecretRef:
    name: iam-management-client
    key: credentials
EOF
```{{exec}}

### **Client Reference for `realm-management`{{}}**

Register a Crossplane-managed representation of the built-in the `realm-management`{{}} Client.

> Note that this client already exists in Keycloak by default - but we need a Kubernetes `Client`{{}} Custom Resource in order to reference the client by name in other CRDs supported by the Keycloak Provider.

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: openidclient.keycloak.m.crossplane.io/v1alpha1
kind: Client
metadata:
  name: realm-management
  namespace: iam-management
spec:
  managementPolicies:
    - Observe
  forProvider:
    realmId: ${REALM}
    clientId: realm-management
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
```{{exec}}
