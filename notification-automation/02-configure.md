Configure the building block using the deployment guide script:

```
bash configure-notification-automation.sh
```{{exec}}

The DNS-01 issuer is only used for optional wildcard TLS. Enter `none` for this HTTP tutorial:

```
none
```{{exec}}

Leave Knative Eventing's service-account token authentication disabled:

```
no
```{{exec}}

Enable the emailer sink. We will deliver messages to Mailpit, a local SMTP server with an inbox you can open in your browser:

```
yes
```{{exec}}

Use these sender and recipient addresses. Mailpit captures the email inside this tutorial; it does not forward it to an external mailbox.

```
notifications@example.com
```{{exec}}

```
attendee@example.com
```{{exec}}

Enter Mailpit's in-cluster SMTP hostname and port:

```
mailpit.notifications.svc.cluster.local
```{{exec}}

```
1025
```{{exec}}

Mailpit accepts these tutorial credentials:

```
notifications@example.com
```{{exec}}

```
tutorial
```{{exec}}

Disable STARTTLS and implicit SSL for the local capture server:

```
false
```{{exec}}

```
false
```{{exec}}

Leave Kafka disabled. The default broker uses an in-memory channel for this exercise:

```
no
```{{exec}}

The script generates GitHub and GitLab webhook secrets in `~/.eoepca/state`. We will use the GitHub secret to sign our sample request.
