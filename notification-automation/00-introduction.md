Welcome to the **[EOEPCA Notification and Automation](https://eoepca.readthedocs.io/projects/notification-automation/en/latest/)** building block tutorial!

Notification and Automation gives the EOEPCA platform an event-driven workflow layer, built on [Knative](https://knative.dev/). Things that happen on the platform (a webhook, a Kubernetes event, another Building Block doing something) get turned into a standard message called a CloudEvent. Anything that wants to react to them can subscribe, without needing to know or care what produced the event.

In this scenario, you will deploy the Notification and Automation Building Block, send it a webhook, watch that webhook arrive as a CloudEvent, and wire up something that reacts to it automatically.

This tutorial can take a little time to start, for example 5 minutes or more, whilst Kubernetes and other prerequisites are installed for you.

---

## What You'll Learn

- Deploy Knative Serving and Eventing, and the Notification and Automation building block on top
- Send a signed GitHub webhook and see it arrive as a CloudEvent
- See Kubernetes cluster activity show up as CloudEvents with zero extra setup
- Wire a Trigger so a downstream automation reacts to an event

---

## Use Case

Imagine you want your EOEPCA platform to *do* something in response to activity: post to Slack when a job fails, run a QA check when new data lands in the catalogue, kick off a pipeline when a GitHub PR is merged. Instead of every Building Block hand-rolling its own integration for each of these, they all just emit CloudEvents onto a shared broker. Anything subscribed to that broker reacts, with no direct connection needed between the source of the event and whatever handles it.

This tutorial deploys the stack, sends a webhook in from the outside, and wires up a notifier function to react to it.

---

## Components Overview

- **Knative Serving** and **Knative Eventing**: the event-routing and serverless-functions control plane, installed via the Knative Operator
- **Webhook source**: turns inbound GitHub/GitLab webhooks into CloudEvents
- **API Server Source**: turns Kubernetes API activity into CloudEvents, with no extra setup
- **CloudEvents player**: a web UI for inspecting events flowing through a broker
- **Emailer sink** and **Kafka** are also available but off by default. This tutorial keeps them off to stay focused; see the [full deployment guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/building-blocks/notification-automation/) for both

Everything lands in the same `default` broker, viewable at any point via the CloudEvents player.

---

## Assumptions

Before we start, you should note that this tutorial assumes a generic knowledge of EOEPCA pre-requisites (Kubernetes, Object Storage, etc...) and some tools installed on your environment (gomplate, etc...). If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial.
