We can now deploy Notification and Automation.

## Install the Knative Operator

Install the Knative Operator before deploying the BB chart:

```
helm repo add knative-operator https://knative.github.io/operator
helm repo update knative-operator

helm upgrade -i knative-operator knative-operator/knative-operator \
  --namespace knative-operator \
  --create-namespace \
  --version v1.19.6 \
  --wait
```{{exec}}

## Apply the Knative Serving and Eventing instances

```
kubectl apply -f generated-knative.yaml
```{{exec}}

This creates the `knative-serving`, `knative-eventing` and `notifications` namespaces, and the `KnativeServing`/`KnativeEventing` custom resources that the operator reconciles into a running control plane (including Kourier, Knative's cluster-internal ingress). Give it a couple of minutes on a fresh cluster while it pulls the component images:

```
kubectl wait --for=condition=Ready knativeserving/knative-serving -n knative-serving --timeout=300s
kubectl wait --for=condition=Ready knativeeventing/knative-eventing -n knative-eventing --timeout=300s
```{{exec}}

## Prepare the tutorial inbox

Mailpit is the SMTP server for this exercise. Its manifest creates a Deployment, Service and browser Ingress in the tutorial namespace:

```
kubectl apply -f /tmp/assets/mailpit.yaml
kubectl rollout status deployment/mailpit -n notifications --timeout=120s
```{{exec}}

## Install the BB chart

This deploys the webhook source (GitHub and GitLab), the API server source, the CloudEvents player, emailer and default broker:

```
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev/
helm repo update eoepca-dev

helm upgrade -i notification-automation eoepca-dev/notification-automation \
  --namespace notifications \
  --create-namespace \
  --version 0.1.2 \
  -f generated-na-values.yaml \
  --wait
```{{exec}}

## Check the deployment

```
kubectl get all -n knative-serving
kubectl get all -n knative-eventing
kubectl get all -n notifications
```{{exec}}

Run the validation script to confirm everything is in place:

```
bash validation.sh
```{{exec}}

Once it's up:

```
curl -s -o /dev/null -w "CloudEvents player: %{http_code}\n" http://cloudevents-player.notifications.eoepca.local
curl -s -o /dev/null -w "Webhook source health: %{http_code}\n" http://webhooks.notifications.eoepca.local/health
```{{exec}}

The CloudEvents player is now available through the Localcoda proxy:

- [Open CloudEvents Player]({{TRAFFIC_HOST1_81}})
