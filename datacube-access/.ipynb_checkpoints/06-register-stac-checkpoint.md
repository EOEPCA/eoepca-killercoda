# Register the metadata in the EOEPCA STAC API

The [Data Access Building Block](https://eoepca.readthedocs.io/projects/data-access/en/latest/) exposes a STAC API. We register the collection and its items, then verify they are queryable.

Activate the Python environment:

```
source ~/datacube-venv/bin/activate
```

## Connect to the STAC API

The STAC API is exposed at `http://eoapi.eoepca.local/stac`. We obtain a token with the public `eoapi` client using the OAuth 2.0 device flow (PKCE).

```
python - <<'PY'
import json, time, hashlib, base64, secrets
import requests, jwt

AUTH_ENDPOINT = "http://auth.eoepca.local/realms/eoepca"
STAC_ENDPOINT = "http://eoapi.eoepca.local/stac"
TOKEN_ENDPOINT = f"{AUTH_ENDPOINT}/protocol/openid-connect/token"
DEVICE_AUTH_ENDPOINT = f"{AUTH_ENDPOINT}/protocol/openid-connect/auth/device"
CLIENT_ID = "eoapi"
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
print(jwt.decode(token, options={"verify_signature": False}))
with open("/tmp/stac-auth.json", "w") as f:
    json.dump({"access_token": token, "stac_endpoint": STAC_ENDPOINT, "collection_id": "eoepcauser.s5p-cf-bp"}, f)
PY
```

{{exec}}

## Confirm the collection does not yet exist

Confirm the STAC API is reachable and that our collection id is not yet registered (a `404` is expected).

```
python - <<'PY'
import json
import requests

auth = json.load(open("/tmp/stac-auth.json"))
stac_endpoint, collection_id, token = auth["stac_endpoint"], auth["collection_id"], auth["access_token"]

resp = requests.get(f"{stac_endpoint}/collections/{collection_id}",
                    headers={"Authorization": f"Bearer {token}"}, timeout=5, allow_redirects=False)
print("PASS (not yet registered)" if resp.status_code == 404 else f"FAIL ({resp.status_code})", "->", resp.status_code)
print("Existing collections:")
for c in requests.get(f"{stac_endpoint}/collections").json()["collections"]:
    print(" -", c["id"])
PY
```

{{exec}}

## Register the collection

```
python - <<'PY'
import json
import requests

auth = json.load(open("/tmp/stac-auth.json"))
stac_endpoint, token = auth["stac_endpoint"], auth["access_token"]
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}

resp = requests.post(
    f"{stac_endpoint}/collections",
    headers=headers,
    json=json.load(open("/tmp/stac-collection-register.json")),
)
print("Collection registration status:", resp.status_code, "->", "PASS" if resp.status_code == 201 else "FAIL")
PY
```

{{exec}}

Register each item:

```
python - <<'PY'
import json
import requests

auth = json.load(open("/tmp/stac-auth.json"))
stac_endpoint, token = auth["stac_endpoint"], auth["access_token"]
collection_id = auth["collection_id"]
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
items_endpoint = f"{stac_endpoint}/collections/{collection_id}/items"

items = json.load(open("/tmp/stac-items-register.json"))
created = 0
for item in items:
    r = requests.post(items_endpoint, headers=headers, json=item)
    r.raise_for_status()
    created += 1
print(f"Uploaded {created}/{len(items)} items")
PY
```

{{exec}}

## Verify registration

Count the items exposed by the STAC API.

```
python - <<'PY'
import json
import requests

auth = json.load(open("/tmp/stac-auth.json"))
stac_endpoint, token, collection_id = auth["stac_endpoint"], auth["access_token"], auth["collection_id"]
params, total, link = {"limit": 250}, 0, f"{stac_endpoint}/collections/{collection_id}/items"
headers = {"Authorization": f"Bearer {token}"}

while link:
    r = requests.get(link, headers=headers, params=params)
    r.raise_for_status()
    body = r.json()
    total += len(body.get("features", []))
    link = next((ln["href"] for ln in body.get("links", []) if ln["rel"] == "next"), None)
    params = {}
print(f"Total items exposed by STAC API: {total}")
PY
```

{{exec}}

**Checkpoint:** the collection and all items are registered in the EOEPCA STAC API and queryable. In the next step we load and process the registered data.