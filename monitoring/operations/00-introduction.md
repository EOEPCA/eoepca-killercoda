Welcome to the **[EOEPCA Operations](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/building-blocks/operations/)** building block tutorial!

The Operations service is the observability stack for an EOEPCA deployment. It gives operators a single place to see what the cluster is doing: metrics, logs, dashboards, and alerts.

In this scenario, you will learn how to deploy and interact with the EOEPCA Operations Building Block — the component responsible for collecting metrics and logs from every other building block, visualising them, and routing alerts to a triage UI.

This tutorial can take a little time to start, for example 5 minutes or more, whilst Kubernetes and other prerequisites are installed for you.

---

### What You'll Learn

- Deploy the Operations building block on Kubernetes
- Explore cluster metrics and logs in Grafana
- Trigger and triage an alert in Keep

---

### Use Case

Imagine you're running an Earth Observation platform made up of several other Building Blocks — data catalogues, processing engines, data access endpoints. You need a single place to confirm they're healthy, to dig into what a failing pod actually logged, and to make sure someone gets paged when something breaks.

With Operations, you can:
- See cluster-wide and per-workload metrics in curated Grafana dashboards
- Search container logs across every namespace from the same UI
- Have Prometheus alerts routed automatically to Keep, where operators acknowledge and triage them

This tutorial deploys the full stack — Prometheus, Alertmanager, Grafana, Loki, Alloy and Keep — and walks through using each of them.

---

### Components Overview

The Operations BB deploys:

- **Prometheus** scrapes metrics from the cluster and from any workload that exposes a `/metrics` endpoint
- **Loki** stores container logs, with **Alloy** collecting them from every node
- **Grafana** is the UI for both, with a set of cluster dashboards loaded out the box
- **Alertmanager** routes firing alerts to **Keep**, which is where operators triage and acknowledge them

Everything is declarative. Alert rules are `PrometheusRule` CRDs, dashboards are ConfigMaps, scrape targets are `ServiceMonitor` CRDs — so new components added to the cluster get picked up without touching any Prometheus config.

> Operations also supports securing Grafana and Keep behind Keycloak SSO. This tutorial deploys it in its simpler default mode — local admin login for Grafana, no authentication for Keep — suitable for a demo environment. See the [Operations Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/building-blocks/operations/) for the IAM-integrated setup.

---

### Assumptions

Before we start, you should note that this tutorial assumes a generic knowledge of EOEPCA pre-requisites (Kubernetes, Object Storage, etc...) and some tools installed on your environment (gomplate, etc...). If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial.
