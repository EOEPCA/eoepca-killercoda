Welcome to the **[EOEPCA Resource Health](https://eoepca.readthedocs.io/projects/resource-health/en/latest/)** building block tutorial!

The Resource Health service provides a flexible framework for monitoring the health and status of resources within the EOEPCA platform. This includes core platform services as well as derived or user-provided resources such as datasets, workflows, or user applications.

In this scenario, you will learn how to deploy and interact with the EOEPCA Resource Health Building Block — a core component responsible for defining, scheduling, and observing automated health checks across your Earth Observation infrastructure.

---

### What You'll Learn

- Deploy the Resource Health building block on Kubernetes
- Create and schedule automated health checks
- View health check results via the web dashboard
- Query the telemetry API for check outcomes

---

### Use Case

Imagine you're running an Earth Observation platform with multiple services — data catalogues, processing engines, and data access endpoints. You need to ensure these services are healthy and available.

With Resource Health, you can:
- Define automated health checks that run on a schedule (hourly, daily, etc.)
- Monitor the outcomes via a centralised dashboard
- Store results in OpenSearch for advanced analytics
- Receive telemetry data via OpenTelemetry for alerting

This tutorial deploys the Resource Health service, creates a sample health check, and demonstrates how to view the results.

---

### Components Overview

The Resource Health BB includes:
- **Resource Health Web** — Dashboard for viewing health checks and results
- **Health Checks API** — For listing, scheduling, and managing checks
- **Telemetry API** — For gathering check results and metrics
- **OpenSearch** — Stores logs, results, and trace data
- **OpenTelemetry Collector** — Receives and forwards telemetry

---

### Assumptions

Before we start, you should note that this tutorial assumes a generic knowledge of EOEPCA pre-requisites (Kubernetes, Object Storage, etc...) and some tools installed on your environment (gomplate, etc...). If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial.

This tutorial deploys Resource Health in a simplified mode without OIDC authentication, suitable for demonstration purposes.