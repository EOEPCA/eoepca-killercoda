Welcome to the **[EOEPCA Application Quality](https://eoepca.readthedocs.io/projects/application-quality/en/latest/)** Building Block tutorial!

The Application Quality BB helps move scientific algorithms from research prototypes to production
workflows. It runs code quality checks, security scans and performance measurements as pipelines on
Kubernetes, and records the results against quality rules that decide whether an application passes.

In this scenario you'll deploy the building block with Keycloak authentication, run one of its
pipelines against a real EOEPCA repository, read the reports it produces, and then define a pipeline
of your own.


---

### What You'll Learn

- Deploy the Application Quality BB with OIDC authentication via Keycloak
- Browse the analysis tools through the API and the web portal
- Execute a pipeline and watch it run on Kubernetes
- Read the reports, the quality verdict and the resource usage of a run
- Define a pipeline with your own quality rules
