Before deploying, we need to configure the Notification and Automation building block. We do this with the configuration script `configure-notification-automation.sh` provided in the EOEPCA deployment guide.

```
bash configure-notification-automation.sh
```{{exec}}

The cert-manager `ClusterIssuer` supporting DNS-01. This is only used for the optional wildcard-cert feature we're skipping in this tutorial (see the previous step), so any value is fine here:

```
none
```{{exec}}

Enable OIDC authentication on eventing resources? This is unrelated to the IAM Building Block. It's Knative Eventing's own token-based auth between eventing resources, not something this tutorial needs:
```
no
```{{exec}}

Enable the emailer sink? Skipped here since it needs a real SMTP server to be useful. See the [full deployment guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/building-blocks/notification-automation/) if you want to wire one up:
```
no
```{{exec}}

Deploy a Kafka cluster for persistent event streaming? Also skipped, the default in-memory channel is enough for this tutorial:
```
no
```{{exec}}

The script also generates random GitHub and GitLab webhook secrets and stores them in `~/.eoepca/state`. We'll use the GitHub one shortly to sign a test webhook.
