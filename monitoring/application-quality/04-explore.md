

With the Application Quality BB deployed, let's explore its capabilities through both the API and web interface.

### Discover the API

The API provides endpoints for managing analysis tools and pipelines:

```
curl -s "http://application-quality.eoepca.local/api/" | jq .
```{{exec}}

The API exposes three main resources: **pipelines**, **tools**, and **tags**.

### List Available Analysis Tools

Retrieve all available analysis tools:

```
curl -s "http://application-quality.eoepca.local/api/tools/" | jq '.[].name'
```{{exec}}

You should see tools including Flake8, Pylint, Bandit, Ruff, Trivy and the OGC Application Package Validator.

### Examine a Tool in Detail

Let's look at Flake8, which checks Python code style:

```
curl -s "http://application-quality.eoepca.local/api/tools/flake8_subworkflow/" | jq '{name, description, user_params}'
```{{exec}}

Key fields:
- **name**: Human-readable tool name
- **description**: What the tool does
- **user_params**: Configurable parameters (e.g. file patterns, verbosity)

### Security Analysis Tools

Bandit detects security vulnerabilities in Python code:

```
curl -s "http://application-quality.eoepca.local/api/tools/bandit_subworkflow/" | jq '{name, description}'
```{{exec}}

Trivy scans container images for vulnerabilities:

```
curl -s "http://application-quality.eoepca.local/api/tools/trivy_subworkflow/" | jq '{name, description}'
```{{exec}}

### OGC Application Package Validator

This tool validates CWL files against OGC Best Practice standards — essential for EOEPCA processing workflows:

```
curl -s "http://application-quality.eoepca.local/api/tools/ap_validator_subworkflow/" | jq .
```{{exec}}

### Browse Tool Categories

Tags categorise tools by asset type and check type:

```
curl -s "http://application-quality.eoepca.local/api/tags/" | jq '.[] | {id, name}'
```{{exec}}

Categories include:
- **asset: python** — Tools for Python code
- **asset: cwl** — Tools for CWL workflow validation
- **asset: docker** — Tools for container analysis
- **type: best practice** — Code quality checks
- **type: app quality** — Security and vulnerability scanning
