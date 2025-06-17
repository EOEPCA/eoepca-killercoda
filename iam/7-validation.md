
## Validating Your Deployment

Now that everything is deployed and set up, let's check that the IAM system is working as expected. We'll use the `validation.sh` script for some quick checks, and also look at the system status ourselves.

### 1. Run the Validation Script

Run the script to carry out some basic tests:

```bash
bash validation.sh
```{{exec}}

### 2. Keycloak Validation

**Authenticate as user `eoepcauser`{{}}**

Call the Keycloak API to obtain an access token.

```bash
source ~/.eoepca/state
ACCESS_TOKEN=$( \
  curl --silent --show-error \
    -X POST \
    -d "username=eoepcauser" \
    --data-urlencode "password=eoepcapassword" \
    -d "grant_type=password" \
    -d "client_id=opa" \
    -d "client_secret=${OPA_CLIENT_SECRET}" \
    "http://auth.eoepca.local/realms/eoepca/protocol/openid-connect/token" | jq -r '.access_token' \
)
```{{exec}}

Check the access token, which will be used in the following steps.

```bash
echo "${ACCESS_TOKEN}"
```{{exec}}

### 3. Open Policy Agent Validation

Check the OPA endpoint with some policy decision requests.

During deployment, OPA was configured with a git repository that provides its policies - https://github.com/EOEPCA/iam-policies.<br>
Ref.

```bash
grep policyRepoUrl generated-values.yaml
```{{exec}}

The following examples use the policy here - https://github.com/EOEPCA/iam-policies/blob/main/policies/example/policies.rego

**Simple 'allow all' policy...**

```bash
curl -X GET "http://opa.eoepca.local/v1/data/example/allow_all" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json"
```{{exec}}

Expect result `{"result":true}`{{}}

**User 'bob' is a privileged use...**

Ref. https://github.com/EOEPCA/iam-policies/blob/main/policies/example/data.json

```bash
curl -X POST "http://opa.eoepca.local/v1/data/example/privileged_user" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"input": {"identity": {"attributes": { "preferred_username": ["bob"]}}}}'
```{{exec}}

Expect result `{"result":true}`{{}}

**User 'eric' is NOT a privileged use...**

```bash
curl -X POST "http://opa.eoepca.local/v1/data/example/privileged_user" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"input": {"identity": {"attributes": { "preferred_username": ["eric"]}}}}'
```{{exec}}

Expect result `{"result":false}`{{}}

**User 'eric' has a verified email**

```bash
curl -X POST "http://opa.eoepca.local/v1/data/example/email_verified" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"input": {"identity": {"attributes": { "preferred_username": ["eric"], "email_verified": ["true"]}}}}'
```{{exec}}

Expect result `{"result":true}`{{}}
