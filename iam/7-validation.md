
## Validating Your Deployment

Now that everything is deployed and set up, let's check that the IAM system is working as expected. We'll use the `validation.sh` script for some quick checks, and also look at the system status ourselves.

### 1. Run the Validation Script

Run the script to carry out some basic tests:

```bash
bash validation.sh
```

### 2. Check Pods and Services

To double-check everything, list the pods and services:

```bash
kubectl get pods -n iam
kubectl get svc -n iam
```

All pods (Keycloak, Postgres, OPAL) should show as Running. Keycloak and OPA services should be `ClusterIP` type, as ingress handles external access. Also, check the APISIX services:

```bash
kubectl -n ingress-apisix get svc
```

If everything looks good, you can try a manual test: get an access token for the test user and call OPA.

```bash
source ~/.eoepca/state

# Get a token from Keycloak
TOKEN=$(curl -k -X POST \
    -d "client_id=admin-cli" -d "grant_type=password" \
    -d "username=${KEYCLOAK_TEST_USER}" -d "password=${KEYCLOAK_TEST_PASSWORD}" \
    "https://${KEYCLOAK_HOST}/realms/eoepca/protocol/openid-connect/token" | jq -r .access_token)

# Use the token to query OPA
curl -k -H "Authorization: Bearer $TOKEN" "https://opa.${INGRESS_HOST}/v1/data/"
```
