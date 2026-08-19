## Crossplane

Crossplane is a Kubernetes add-on that enables the management of cloud infrastructure and services using Kubernetes-native APIs.

The Crossplane deployment comprises a core system deployment, which is then extended via the installation of Providers. Each Provider enables the management of a specific type of infrastructure or service, such as Kubernetes clusters, cloud storage, databases, etc.

One such provider is the Keycloak Provider, which allows for the management of Keycloak resources such as Realms, Clients, and Users using Kubernetes manifests.

The Crossplane core was already deployed as a prerequisite to this tutorial - with additional providers including the Keycloak Provider...

```bash
kubectl -n crossplane-system get pod
```{{exec}}

The Crossplane Keycloak Provider has been set up by the Helm Chart to be able to manage the Keycloak service. This includes managing OIDC client, roles, groups, and users. Here we use it to add a test user.

## Adding a User via Crossplane

> A test users is created with the username and password that were specified during IAM configuration.
> Defaults (unless otherwise specified) are:
> * Username: `eoepcauser`{{}}
> * Password: `eoepcapassword`{{}}

The user is created declaratively using the CRD defined by the Crossplane Keycloak provider.

### **Password**

A Secret is used to inject the password securely.

```bash
source ~/.eoepca/state
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: test-user-password
  namespace: iam-management
stringData:
  password: ${KEYCLOAK_TEST_PASSWORD}
EOF
```{{exec}}

### **Create Users**

```bash
source ~/.eoepca/state

cat <<EOF | kubectl apply -f -
apiVersion: user.keycloak.m.crossplane.io/v1alpha1
kind: User
metadata:
  name: eoepca-user
  namespace: iam-management
spec:
  forProvider:
    realmId: eoepca
    username: ${KEYCLOAK_TEST_USER}
    email: ${KEYCLOAK_TEST_USER}@eoepca.org
    emailVerified: true
    firstName: ${KEYCLOAK_TEST_USER}
    lastName: Testuser
    initialPassword:
      - temporary: false
        valueSecretRef:
          name: test-user-password
          key: password
  providerConfigRef:
    name: keycloak-provider-config
    kind: ProviderConfig
EOF
```{{exec}}

### **Verify Users**

Login to the [Keycloak Admin Console]({{TRAFFIC_HOST1_90}}/admin/master/console/#/eoepca/users) to check the users have been created by the Keycloak Provider from the _Custom Resources_ - using the `admin`{{}} credentials defined in the `~/.eoepca/state`{{}} file.

```bash
grep KEYCLOAK_ADMIN_ ~/.eoepca/state
```{{exec}}

> Navigate to the `eoepca`{{}} realm, then to the `Users`{{}} section to see the created test users.
