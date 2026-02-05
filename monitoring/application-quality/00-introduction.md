Welcome to the **[EOEPCA Application Quality](https://eoepca.readthedocs.io/projects/application-quality/en/latest/)** Building Block tutorial!

The Application Quality BB helps transition scientific algorithms from research prototypes to production-ready workflows. It orchestrates code quality checks, security scans, vulnerability detection and performance testing through configurable pipelines.

In this scenario, you'll deploy the Application Quality BB with full authentication, create a quality pipeline and run it against a real image.

Before proceeding - wait for all prerequisite services to be ready...

```bash
echo "Waiting for readiness"
until kubectl wait --for=condition=Ready --all=true -A pod --timeout=1m &>/dev/null; do
  sleep 2
  echo "Waiting for readiness"
done
```{{exec}}

---

### What You'll Learn

- Deploy the Application Quality BB with OIDC authentication via Keycloak
- Navigate the web portal and understand its capabilities
- Execute a pipeline
- View analysis results
