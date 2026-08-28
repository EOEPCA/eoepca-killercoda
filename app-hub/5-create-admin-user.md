
## Create an Admin User

The Application Hub has a default admin user named `eric` configured in its profiles. We need to create this user in Keycloak.

`configure-app-hub.sh` already rendered `generated-demo-user.yaml`, which creates this user declaratively via the Crossplane Keycloak provider's User CRD. Apply it:

```bash
kubectl apply -f generated-demo-user.yaml
```{{exec}}

You can now log in to the Application Hub as Admin with:
- Username: `eric`
- Password: `eoepcapassword`
