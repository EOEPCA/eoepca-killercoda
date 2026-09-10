We will notify an attendee when a GitHub push arrives. The webhook source checks the signature and creates a CloudEvent; a Trigger selects push events and delivers them to the emailer.

## Send a signed webhook

This sample represents a push to the deployment guide's `release-2.1` branch. It does not change the GitHub repository.

```
source ~/.eoepca/state
PAYLOAD='{"repository":{"html_url":"https://github.com/EOEPCA/deployment-guide"},"ref":"refs/heads/release-2.1"}'
SIGNATURE="sha256=$(printf '%s' "$PAYLOAD" | openssl dgst -sha256 -hmac "$NA_GITHUB_WEBHOOK_SECRET" | cut -d ' ' -f 2)"

curl -sS -w '\nHTTP %{http_code}\n' \
  "http://webhooks.notifications.eoepca.local/github" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: $SIGNATURE" \
  -d "$PAYLOAD"
```{{exec}}

Expect `HTTP 202`: the broker accepted the event. Check the player to see delivery:

```
curl -sS http://cloudevents-player.notifications.eoepca.local/messages | jq
```{{exec}}

Look for `org.eoepca.webhook.github.push` and the repository URL and branch in the event data. If it has not arrived yet, run the request again after a few seconds.

[Open CloudEvents Player]({{TRAFFIC_HOST1_81}})

The API returns the ten most recent events by default. If cluster activity has moved your event out of that list, use `/messages?size=200` or find it in the browser's Activity table.

The player subscribes to all events in the `default` broker. The emailer has no subscription yet, so the inbox should still be empty:

[Open tutorial inbox]({{TRAFFIC_HOST1_83}})

## Subscribe the emailer to push events

A Trigger selects events from a broker for one subscriber. The player keeps its unfiltered subscription; this second Trigger delivers only GitHub push events to the emailer:

```
cat <<EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: emailer-github
  namespace: notifications
spec:
  broker: default
  filter:
    attributes:
      type: org.eoepca.webhook.github.push
  subscriber:
    ref:
      apiVersion: v1
      kind: Service
      name: notification-automation-emailer
EOF

kubectl wait --for=condition=Ready trigger/emailer-github -n notifications --timeout=120s
```{{exec}}

Send another push using the same payload and signature. The new Trigger receives new events; it does not replay the push sent before it existed:

```
curl -sS -w '\nHTTP %{http_code}\n' \
  "http://webhooks.notifications.eoepca.local/github" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: $SIGNATURE" \
  -d "$PAYLOAD"
```{{exec}}

Open the new message in the [tutorial inbox]({{TRAFFIC_HOST1_83}}). Check the recipient, event type, repository and branch. Match the event `id` in the email body to its entry in the CloudEvents player. This is an email delivered over SMTP by the BB's emailer, captured locally by Mailpit.

You can also inspect the inbox through its API:

```
curl -sS http://mailpit.notifications.eoepca.local/api/v1/messages | jq
```{{exec}}

Once the inbox contains the new email, read the latest message, including its body:

```
MESSAGE_ID=$(curl -sS http://mailpit.notifications.eoepca.local/api/v1/messages | jq -r '.messages[0].ID')
curl -sS "http://mailpit.notifications.eoepca.local/api/v1/message/$MESSAGE_ID" | jq
```{{exec}}

Check the emailer logs for the delivery:

```
kubectl logs -n notifications deployment/notification-automation-emailer --tail=20
```{{exec}}

## Observe the Trigger filter

Create a Kubernetes Event in the namespace watched by the API Server Source:

```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Event
metadata:
  name: notification-demo
  namespace: notifications
involvedObject:
  apiVersion: apps/v1
  kind: Deployment
  name: notification-automation-emailer
  namespace: notifications
reason: WorkshopDemo
message: The notification tutorial is running
type: Normal
EOF
```{{exec}}

```
curl -sS http://cloudevents-player.notifications.eoepca.local/messages | jq
```{{exec}}

Look for a `dev.knative.apiserver.ref.add` event referencing `notification-demo`. If it has not arrived yet, repeat the request after a few seconds. The API Server Source sends an object reference; inspect the original object to read its message:

```
kubectl get event notification-demo -n notifications -o yaml
```{{exec}}

The event appears in the player but produces no email: its type does not match the emailer Trigger. Refresh the inbox to check. The source watches this namespace, not every building block in the cluster.

Remove the sample Kubernetes Event when finished:

```
kubectl delete event notification-demo -n notifications
```{{exec}}

Leave the Trigger and inbox running. You can send more signed push requests and inspect the resulting notifications. The broker and inbox use temporary storage in this exercise; they are not a durable event archive.
