You have sent a signed webhook, inspected its CloudEvent and used a filtered Trigger to deliver an email. You also created a Kubernetes Event and observed that it reached the player without matching the email subscription.

The [CloudEvents player]({{TRAFFIC_HOST1_81}}), [tutorial inbox]({{TRAFFIC_HOST1_83}}) and emailer subscription remain available for further requests.

For external SMTP, optional Kafka and your own Knative functions, see the [Notification and Automation deployment guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/building-blocks/notification-automation/). You can also return to the [EOEPCA tutorials](https://killercoda.com/eoepca/).
