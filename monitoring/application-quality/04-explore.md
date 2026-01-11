Now that the Application Quality Building Block is deployed, let's explore its API and understand the available analysis tools.

### Discover the API

The Application Quality API provides endpoints for managing analysis tools and pipelines. Let's start by checking what's available:

```
curl -s "http://application-quality.eoepca.local/api/" | jq .
```{{exec}}

The API exposes three main resources: pipelines, tools, and tags.

### List Available Analysis Tools

The tools endpoint returns all available analysis tools that can be used in quality pipelines:

```
curl -s "http://application-quality.eoepca.local/api/tools/" | jq '.[].name'
```{{exec}}

You should see tools like Flake8, Pylint, Bandit, Ruff, Trivy, and others. Each tool is a containerised analysis component that can be orchestrated in pipelines.

### Explore Tool Details

Let's look at a specific tool in detail. The Flake8 tool checks Python code style:

```
curl -s "http://application-quality.eoepca.local/api/tools/flake8_subworkflow/" | jq .
```{{exec}}

Key fields in the response:
- **slug**: Unique identifier for the tool
- **name**: Human-readable name
- **description**: What the tool does
- **user_params**: Configurable parameters when running the tool
- **tags**: Categories this tool belongs to
- **tools**: The underlying CWL workflow steps

### View Security Analysis Tools

Bandit is a security-focused tool that finds common vulnerabilities in Python code:

```
curl -s "http://application-quality.eoepca.local/api/tools/bandit_subworkflow/" | jq .
```{{exec}}

Trivy scans container images for vulnerabilities:

```
curl -s "http://application-quality.eoepca.local/api/tools/trivy_subworkflow/" | jq .
```{{exec}}

### Browse Tool Categories

Tags help categorise tools by the type of asset they analyse or the type of check they perform:

```
curl -s "http://application-quality.eoepca.local/api/tags/" | jq .
```{{exec}}

You'll see categories like:
- **asset: python** — Tools for Python code
- **asset: notebook** — Tools for Jupyter notebooks
- **asset: cwl** — Tools for CWL workflow validation
- **asset: docker** — Tools for container analysis
- **type: best practice** — Code quality and style checks
- **type: app quality** — Security and vulnerability scanning
- **type: app performance** — Performance testing tools

### Filter Tools by Type

To find all Python-related tools, you can filter the results:

```
curl -s "http://application-quality.eoepca.local/api/tools/" | jq '[.[] | select(.tags | contains([1]))]'
```{{exec}}

This filters tools that have tag ID 1 (asset: python).

### Understanding the Tool Structure

Each tool is implemented as a CWL (Common Workflow Language) subworkflow. For example, looking at Pylint:

```
curl -s "http://application-quality.eoepca.local/api/tools/pylint_subworkflow/" | jq '.user_params'
```{{exec}}

The `user_params` define what can be configured when the tool runs:
- **filter.regex**: Which files to analyse (default: `.*\.py`)
- **pylint.verbose**: Enable verbose output
- **pylint.errors_only**: Only report errors, not warnings
- **pylint.disable**: Disable specific checks by ID

### Application Package Validator

A particularly useful tool for EOEPCA is the Application Package Validator, which checks CWL files for OGC compliance:

```
curl -s "http://application-quality.eoepca.local/api/tools/ap_validator_subworkflow/" | jq .
```{{exec}}

This validates that your application packages follow the OGC Best Practice standards.

### Pipeline Execution (Requires Authentication)

To create and execute pipelines, authentication is required. In a production deployment with OIDC configured, you would:

1. Authenticate via Keycloak to obtain a session
2. Create a pipeline combining multiple tools
3. Execute the pipeline against a Git repository
4. Monitor execution progress and view results

```
# This endpoint requires authentication
curl -s "http://application-quality.eoepca.local/api/pipelines/" | jq .
```{{exec}}

For full pipeline functionality, deploy with OIDC authentication enabled as described in the [EOEPCA Deployment Guide](https://deployment-guide.docs.eoepca.org/current/building-blocks/application-quality/).

### Access the Web Interface

The Application Quality web portal provides a graphical interface for:
- Browsing available tools and their documentation
- Creating and managing pipelines
- Executing pipelines against repositories
- Viewing execution results and reports

Access it at [Application Quality Portal]({{TRAFFIC_HOST1_80}}).

Without OIDC authentication, you can browse the interface but won't be able to log in or execute pipelines.
