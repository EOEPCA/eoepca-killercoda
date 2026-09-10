Notification and Automation routes CloudEvents between event sources and subscribers using Knative.

In this tutorial you will:

- Deploy Knative Serving, Eventing and the Notification and Automation building block.
- Send a signed GitHub webhook and inspect its CloudEvent in the player.
- Subscribe the emailer to push events and open the resulting email in a local inbox.
- Create a Kubernetes Event and see how a Trigger filter selects which events cause notifications.

The workflow uses the BB's webhook source, default broker, CloudEvents player, API Server Source and emailer. Mailpit supplies a local SMTP server and browser inbox for the exercise. No GitHub account or external email service is needed.

Kafka remains disabled. The in-memory broker is suitable for this exercise; durable event storage requires additional configuration.

Allow a few minutes for Kubernetes and the tutorial prerequisites to start. Deployment commands follow the [EOEPCA deployment guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/building-blocks/notification-automation/).
