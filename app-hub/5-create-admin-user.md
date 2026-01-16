
## Create an Admin User

The Application Hub has a default admin user named `eric` configured in its profiles. We need to create this user in Keycloak.

Create the admin user using the Crossplane User CRD:

```bash
source ~/.eoepca/state
username="eric"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: ${username}-user-password
  namespace: iam-management
stringData:
  password: ${KEYCLOAK_TEST_PASSWORD:-eoepca}
---
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
          name: ${username}-user-password
          key: password
  providerConfigRef:
    name: provider-keycloak
    kind: ProviderConfig
EOF
```{{exec}}

You can now log in to the Application Hub as Admin with:
- Username: `eric`
- Password: `eoepcapassword`