Time to see events flow through the system. A quick note before we start: there is no real GitHub repository and no real Slack workspace involved anywhere in this step. We fake GitHub by sending the exact same kind of HTTP request GitHub would send. We fake Slack with a web address that doesn't exist, so nothing gets posted anywhere, but we can still prove the message would have been sent by reading a log.

## Step 1: Send a fake GitHub webhook

When code is pushed to a real GitHub repository, GitHub sends an HTTP request to whatever URL you've configured, and signs that request with a secret so the receiver knows it's genuinely from GitHub. We're going to send that same kind of request ourselves, signed with the secret our configuration script generated earlier.

Run this:

```
source ~/.eoepca/state
PAYLOAD='{"repository": {"html_url": "https://github.com/EOEPCA/deployment-guide"}, "ref": "refs/heads/main"}'
SIGNATURE="sha256=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac "$NA_GITHUB_WEBHOOK_SECRET" | awk '{print $NF}')"

curl -X POST "http://webhooks.notifications.eoepca.local/github" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: $SIGNATURE" \
  -d "$PAYLOAD"
```{{exec}}

A response of `202` means the webhook source accepted the request and forwarded it as an event onto the `default` broker. Think of the broker as a mailbox: anything can drop an event in, and anything else can subscribe to read from it.

## Step 2: Check the event arrived

The CloudEvents player is a small web page that shows every event passing through the broker. Query it directly:

```
curl -s "http://cloudevents-player.notifications.eoepca.local/messages" \
  | jq '.[] | select(.eventType == "org.eoepca.webhook.github.push")'
```{{exec}}

You should see the event we just sent, with our payload inside it. You can also open the player in your browser and watch new events appear as you send them:

[Open CloudEvents Player]({{TRAFFIC_HOST1_81}})

## Step 3: See cluster activity arrive automatically

There's a second source already running, called the API Server Source. It watches Kubernetes for things happening on the cluster (a pod starting, a job finishing, and so on) and drops each one onto the same broker. We didn't have to configure anything for this, it's on by default.

Count how many of these cluster events have shown up so far:

```
curl -s "http://cloudevents-player.notifications.eoepca.local/messages" \
  | jq '[.[] | select(.eventType | startswith("dev.knative.apiserver"))] | length'
```{{exec}}

This is the same mechanism any EOEPCA Building Block can use to become an event source: as long as something it does shows up as a Kubernetes `Event`, it's already flowing into this broker with no extra setup.

## Step 4: React to an event automatically

Now let's make something happen automatically when a GitHub push event arrives. We'll deploy a small prebuilt app called `send-notification-to-slack`, whose only job is to take a CloudEvent and post its contents to Slack. Then we'll create a Trigger, which is the piece that says "send events of this type to that app".

```
cat <<EOF | kubectl apply -f -
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: slack-notifier
  namespace: notifications
spec:
  template:
    spec:
      containers:
        - image: ghcr.io/eoepca/send-notification-to-slack:latest
          env:
            - name: SLACK_WEBHOOK_URL
              value: "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
EOF

cat <<EOF | kubectl apply -f -
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: slack-notifier-github
  namespace: notifications
spec:
  broker: default
  filter:
    attributes:
      type: org.eoepca.webhook.github.push
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: slack-notifier
EOF

kubectl wait --for=condition=Ready ksvc/slack-notifier -n notifications --timeout=120s
```{{exec}}

The `SLACK_WEBHOOK_URL` above is fake, so it can't actually post anywhere. That's fine for this tutorial, we're only proving the pieces are wired together correctly.

Wait a minute for the service to start up and now re-send the same webhook from Step 1:

```
SIGNATURE="sha256=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac "$NA_GITHUB_WEBHOOK_SECRET" | awk '{print $NF}')"

curl --max-time 5 -X POST "http://webhooks.notifications.eoepca.local/github" \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-Hub-Signature-256: $SIGNATURE" \
  -d "$PAYLOAD"
```{{exec}}

This command will time out after 5 seconds and print an error. That's expected, ignore it. It happens because `send-notification-to-slack` doesn't reply in the exact format Knative expects, so Knative assumes delivery failed and keeps retrying in the background, even though the app already got the event. 

To see what actually happened, check the app's own logs:

```
kubectl logs -n notifications -l serving.knative.dev/service=slack-notifier -c user-container --tail=20
```{{exec}}

You should see it received the event, tried to post to Slack, and got an error, because the Slack address is fake. That error is proof the whole chain worked: webhook in, broker, Trigger, and our app, all the way through. Point `SLACK_WEBHOOK_URL` at a real [Slack Incoming Webhook](https://api.slack.com/apps) and the same setup would post for real.
