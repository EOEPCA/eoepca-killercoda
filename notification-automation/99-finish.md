We have learned in this tutorial how to deploy the EOEPCA Notification and Automation Building Block, send events in via a signed webhook, see cluster activity flow in for free, and wire a real downstream automation to react to an event via a Knative Trigger.

From here you could point `slack-notifier`'s `SLACK_WEBHOOK_URL` at a real Slack app to see it actually post, deploy the emailer sink instead, or write your own automation with the `func` CLI. See the [full deployment guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/building-blocks/notification-automation/) for all of that, plus Kafka as a durable event backbone and the real EOEPCA integration with Data Access's STAC notifications. Or jump to another one of the [EOEPCA Tutorials](https://killercoda.com/eoepca/).

For more information about EOEPCA and the EOEPCA Notification and Automation Building Block, have a look at the:
 - [EOEPCA Website](https://eoepca.org/)
 - [EOEPCA Git Repository](https://github.com/EOEPCA/)
 - [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/)
 - [General EOEPCA Documentation](https://eoepca.readthedocs.io/)
 - [Knative Eventing Documentation](https://knative.dev/docs/eventing/)
 - [CloudEvents Specification](https://cloudevents.io/)

and if you have questions about this tutorial, EOEPCA in general or specific EOEPCA applications, you can contact us using [this form](https://github.com/EOEPCA/community-support/issues/new?template=eoepca-support-request.yaml).
