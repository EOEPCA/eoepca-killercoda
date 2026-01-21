
> Test users (admin and normal user) are created with the usernames and password that were specified during IAM configuration.
> Defaults (unless otherwise specified) are:
> * Admin User: `eoepcaadmin`{{}}
> * Normal User: `eoepcauser`{{}}
> * Password: `eoepcapassword`{{}} (both)

The users are created declaratively using the CRD defined by the Crossplane Keycloak provider.

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
for username in ${KEYCLOAK_TEST_ADMIN} ${KEYCLOAK_TEST_USER}; do
cat <<EOF | kubectl apply -f -
apiVersion: user.keycloak.m.crossplane.io/v1alpha1
kind: User
metadata:
  name: ${username}
  namespace: iam-management
spec:
  forProvider:
    realmId: eoepca
    username: ${username}
    email: ${username}@eoepca.org
    emailVerified: true
    firstName: ${username}
    lastName: Testuser
    initialPassword:
      - temporary: false
        valueSecretRef:
          name: test-user-password
          key: password
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
done
```{{exec}}

### **Verify Users**

Login to the [Keycloak Admin Console]({{TRAFFIC_HOST1_90}}/admin/master/console/#/eoepca/users) to check the users have been created by the Keycloak Provider from the _Custom Resources_ - using the `admin`{{}} credentials defined in the `~/.eoepca/state`{{}} file.

```bash
grep KEYCLOAK_ADMIN_ ~/.eoepca/state
```{{exec}}

> Navigate to the `eoepca`{{}} realm, then to the `Users`{{}} section to see the created test users.
