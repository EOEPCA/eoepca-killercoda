
With the Application Quality BB deployed, let's look at what it offers through its API. Set the
public URL once, so the following commands stay short:

```bash
source ~/.eoepca/state
export AQ_URL="${HTTP_SCHEME}://${APP_QUALITY_PUBLIC_HOST}"
echo "$AQ_URL"
```{{exec}}

### Discover the API

```
curl -sS "$AQ_URL/api/" | jq
```{{exec}}

The API exposes analysis **tools**, **tags**, **pipelines**, and the **triggers** that can start a
pipeline automatically from an external event.

### List the available analysis tools

```
curl -sS "$AQ_URL/api/tools/" | jq -r '.[].name'
```{{exec}}

Each tool is a CWL sub-workflow that runs in its own container: linters such as Flake8, Pylint and
Ruff, the security scanner Bandit, the container image scanner Trivy, and validators for Jupyter
notebooks and OGC Application Packages.

### Examine a tool in detail

Bandit finds common security issues in Python code:

```
curl -sS "$AQ_URL/api/tools/bandit_subworkflow/" | jq
```{{exec}}

`user_params`{{}} are the inputs you can set when a pipeline runs the tool. Bandit takes a
`filter.regex`{{}} selecting which files to analyse, and a `verbose`{{}} flag.

Compare that with Trivy, which scans a container image rather than source files:

```
curl -sS "$AQ_URL/api/tools/trivy_subworkflow/" | jq
```{{exec}}

### Browse the tool categories

Tags group the tools by the asset they analyse and the kind of check they perform:

```
curl -sS "$AQ_URL/api/tags/" | jq -r '.[].name'
```{{exec}}

Tools and tags are readable without logging in. Pipelines and their runs are not - that is what we
set up next.
