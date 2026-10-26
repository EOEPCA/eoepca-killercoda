# Save the metadata to the EOEPCA Workspace

The [Workspace Building Block](https://eoepca.readthedocs.io/projects/workspace/en/latest/) provides S3-compatible storage for the prepared STAC metadata and derived products. We create a workspace, wait until it is ready, then upload the catalog directory produced in the previous step.

Activate the Python environment:

```
source ~/datacube-venv/bin/activate
```

## Connect to the Workspace API

The workspace API is exposed at `http://workspace-api.eoepca.local/workspaces`. We use the public `workspace-api` client with the OAuth 2.0 device flow (PKCE) so no client secret is required.

```
python - <<'PY'
import json, time, hashlib, base64, secrets
import requests, jwt

AUTH_ENDPOINT = "http://auth.eoepca.local/realms/eoepca"
WORKSPACE_API_ENDPOINT = "http://workspace-api.eoepca.local/workspaces"
TOKEN_ENDPOINT = f"{AUTH_ENDPOINT}/protocol/openid-connect/token"
DEVICE_AUTH_ENDPOINT = f"{AUTH_ENDPOINT}/protocol/openid-connect/auth/device"
CLIENT_ID = "workspace-api"
SCOPE = "roles offline_access"

verifier = secrets.token_urlsafe(64)
challenge = base64.urlsafe_b64encode(
    hashlib.sha256(verifier.encode()).digest()).decode().rstrip("=")

da = requests.post(DEVICE_AUTH_ENDPOINT, data={
    "client_id": CLIENT_ID, "code_challenge": challenge,
    "code_challenge_method": "S256", "scope": SCOPE}, timeout=30).json()
print("Open:", da["verification_uri"])
print("Enter code:", da["user_code"])

data = {"grant_type": "urn:ietf:params:oauth:grant-type:device_code",
        "device_code": da["device_code"], "client_id": CLIENT_ID, "code_verifier": verifier}
start = time.time()
while True:
    if time.time() - start > 600:
        raise TimeoutError("Device auth timed out")
    resp = requests.post(TOKEN_ENDPOINT, data=data, timeout=30)
    if resp.ok:
        break
    err = resp.json().get("error")
    if err in ("authorization_pending", "slow_down"):
        time.sleep(da.get("interval", 5) + (5 if err == "slow_down" else 0)); continue
    raise RuntimeError(f"Device flow failed: {err}")

token = resp.json()["access_token"]
print(json.dumps(jwt.decode(token, options={"verify_signature": False}), indent=2))
with open("/tmp/workspace-auth.json", "w") as f:
    json.dump({"access_token": token, "workspace_api_endpoint": WORKSPACE_API_ENDPOINT}, f)
PY
```

{{exec}}

## Create and wait for the workspace

Create a workspace, then poll until the status is `ready`.

```
python - <<'PY'
import json, time
import requests

auth = json.load(open("/tmp/workspace-auth.json"))
token, ws_endpoint = auth["access_token"], auth["workspace_api_endpoint"]
headers = {"Authorization": f"Bearer {token}"}

resp = requests.post(ws_endpoint, headers=headers,
                     json={"preferred_name": "eoepcauser-workspace", "default_owner": "eoepcauser"})
resp.raise_for_status()
ws_name = resp.json()["name"]
print(f"Created workspace '{ws_name}'")

while True:
    s = requests.get(f"{ws_endpoint}/{ws_name}", headers=headers).json()
    print("status:", s.get("status"))
    if s.get("status") == "ready":
        break
    time.sleep(20)

json.dump(s["storage"]["credentials"], open("/tmp/workspace-s3.json", "w"))
print("Workspace ready. S3 bucket:", s["storage"]["credentials"]["bucketname"])
PY
```

{{exec}}

## Upload the metadata directory

Upload every file under the `eoepcauser.s5p-cf-bp-stac-catalog` directory to the workspace using the S3 credentials, mirroring the `end2end/{catalog_id}/` prefix.

```
python - <<'PY'
import json, os
import boto3

creds = json.load(open("/tmp/workspace-s3.json"))
s3 = boto3.session.Session().resource(
    "s3", aws_access_key_id=creds["access"], aws_secret_access_key=creds["secret"],
    endpoint_url=creds["endpoint"])

catalog_id = "eoepcauser.s5p-cf-bp-stac-catalog"
bucket, prefix = creds["bucketname"], f"end2end/{catalog_id}/"

uploaded = 0
for root, dirs, files in os.walk(catalog_id):
    for file in files:
        local = os.path.join(root, file)
        s3_key = os.path.join(prefix, os.path.relpath(local, catalog_id)).replace("\\", "/")
        with open(local, "rb") as data:
            s3.Object(bucket, s3_key).put(Body=data)
        uploaded += 1
        print(f"Uploaded {s3_key} ({uploaded} files)")

print(f"Successfully uploaded {uploaded} files to s3://{bucket}/{prefix}")
PY
```

{{exec}}

**Checkpoint:** the STAC metadata catalog is stored in the EOEPCA Workspace. In the next step we register the collection and items in the EOEPCA STAC API.