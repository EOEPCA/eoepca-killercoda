
## Validating Your Deployment

Now that everything is deployed and set up, let's check that the IAM system is working as expected. We'll use the `validation.sh` script for some quick checks, and also look at the system status ourselves.

### 1. Run the Validation Script

Run the script to carry out some basic tests:

```bash
bash validation.sh
```

This script checks that Keycloak and OPA are up and responding. For example, it might try to get an access token from Keycloak and use it to query OPA, or check that the OpenID configuration is available. Watch the output for any errors. If all goes well, you'll see that the authentication and policy services are reachable (using the ingress host URLs).

If you get errors about TLS certificates (because we're using self-signed certs), the script might be using `curl` with the `-k` option to skip certificate checks. You can also test this yourself with:

```bash
curl -k https://auth.${INGRESS_HOST}
```

Or, if you prefer, add your self-signed CA to your trusted certificates. In this setup, `auth.${INGRESS_HOST}` (for example, `auth.example.com`) points to your local cluster.

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

You should see the `apisix-gateway` service with NodePorts 31080/31443, and an `apisix-ingress-controller` service. The gateway routes `auth.${INGRESS_HOST}` and `opa.${INGRESS_HOST}` traffic to the IAM pods.

If everything looks good, you can try a manual test: get an access token for the test user and call OPA.

```bash
source ~/.eoepca/state

export KEYCLOAK_TEST_USER="eoepcauser"
export KEYCLOAK_TEST_PASSWORD="eoepcapassword"

# Get a token from Keycloak
TOKEN=$(curl -sk -X POST \
    -d "client_id=admin-cli" -d "grant_type=password" \
    -d "username=${KEYCLOAK_TEST_USER}" -d "password=${KEYCLOAK_TEST_PASSWORD}" \
    "https://auth.${INGRESS_HOST}/realms/eoepca/protocol/openid-connect/token" | jq -r .access_token)

# Use the token to query OPA
curl -sk -H "Authorization: Bearer $TOKEN" "https://opa.${INGRESS_HOST}/v1/data/"
```
