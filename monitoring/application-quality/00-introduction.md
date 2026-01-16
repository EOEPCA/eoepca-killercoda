Welcome to the **[EOEPCA Application Quality](https://eoepca.readthedocs.io/projects/application-quality/en/latest/)** building block tutorial!

The Application Quality Building Block supports the transition of scientific algorithms from research prototypes to production-grade workflows. It provides tooling for code quality verification, security scanning, vulnerability detection, and performance testing — all orchestrated through configurable pipelines integrated into CI/CD processes.

In this scenario, you will deploy the EOEPCA Application Quality Building Block and explore its architecture and capabilities.

---

### What You'll Learn

- Deploy the Application Quality building block on Kubernetes
- Understand the component architecture (web portal, API, database, pipeline engine)
- Explore the web interface for pipeline management
- Learn how quality pipelines integrate analysis tools

---

### Use Case

Imagine you're developing Earth Observation processing workflows and need to ensure they meet quality standards before deployment. The Application Quality BB allows you to:

- Run static code analysis (flake8, ruff, bandit, SonarQube)
- Perform vulnerability scanning on containers (Trivy)
- Execute performance tests on workflows
- Generate documentation automatically (Sphinx)
- Orchestrate these checks in automated pipelines

---

### Components Overview

The Application Quality BB includes:

- **Web Portal** — User interface for creating and managing pipelines
- **Backend API** — RESTful services for pipeline orchestration
- **Database** — Stores tool definitions, pipeline configurations, and execution metadata
- **Pipeline Engine** — Manages workflow execution using CWL (Common Workflow Language)
- **Calrissian** — CWL runner that executes workflow steps in Kubernetes containers
- **OpenSearch** (optional) — Stores and visualises pipeline execution results

---

### Important Note

The Application Quality BB is designed to work with OIDC authentication via APISIX ingress. In this tutorial, we deploy a simplified version using nginx ingress without full OIDC integration. This means:

- The deployment will be functional but with limited interactive features
- Read-only browsing of the web interface will be available
- Full pipeline execution and authenticated features require OIDC (covered in the full deployment guide)

This tutorial focuses on understanding the architecture and deployment process.

---

### Assumptions

This tutorial assumes familiarity with EOEPCA prerequisites (Kubernetes, Helm, etc.). If you want to replicate this on your own environment with full OIDC support, follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial and the complete deployment guide.