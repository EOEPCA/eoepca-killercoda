
Pipelines are not fixed: you can define your own from the available tools, with your own quality
rules. Let's build a security-only pipeline and see how the rules change the verdict.

### Create a pipeline

This pipeline clones a repository and runs Bandit on it. Its `pass`{{}} rule ignores style findings
and only fails on security or critical issues:

```bash
PIPELINE=$(
  curl -sS -X POST "$AQ_URL/api/pipelines/" \
    -H "Authorization: Bearer $AQ_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name": "Security scan", "version": "1.0", "description": "Clone a repository and scan its Python code with Bandit", "tools": ["clone_subworkflow", "bandit_subworkflow"], "quality_rules": {"pass": "security == 0 and critical == 0"}}'
)
export PIPELINE_ID=$(echo "$PIPELINE" | jq -r '.id')
echo "$PIPELINE" | jq
```{{exec}}

The pipeline now appears under **Pipelines** in the portal, alongside the built-in ones.

### Run it against the same repository

```bash
RUN=$(
  curl -sS -X POST "$AQ_URL/api/pipelines/$PIPELINE_ID/runs/" \
    -H "Authorization: Bearer $AQ_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"parameters": {"clone_subworkflow": {"clone": {"repo_url": "https://github.com/EOEPCA/app-package-validation", "repo_branch": "main"}}}}'
)
export RUN_ID=$(echo "$RUN" | jq -r '.id')
echo "$RUN" | jq
```{{exec}}

Check the pods come up in the run's namespace:

```
kubectl get pods -n applicationqualitypipeline-$RUN_ID
```{{exec}}

With only one analysis tool this run usually finishes sooner. Check it until the status is
`succeeded`{{}}:

```
curl -sS -H "Authorization: Bearer $AQ_TOKEN" "$AQ_URL/api/pipelines/$PIPELINE_ID/runs/$RUN_ID/" | jq
```{{exec}}

Compare `digest`{{}} with the first run. This rule permits warnings, but still fails on security
or critical issues. A passing verdict means the findings meet this rule; it does not mean that
Bandit found no issues.

### Look at what Bandit found

```
curl -sS "$AQ_URL/api/pipelines/$PIPELINE_ID/runs/$RUN_ID/jobreports/?name=bandit" | jq '.[0].output.results'
```{{exec}}

Each result names the test that fired, the file and line, and the severity and confidence Bandit
assigned to it.

### Where to go next

The pipeline stays in the deployment, so you can keep experimenting: add another tool to it, point it
at one of your own repositories, or run it again from the portal and watch it under **Monitoring**.

```
curl -sS -H "Authorization: Bearer $AQ_TOKEN" "$AQ_URL/api/pipelines/$PIPELINE_ID/runs/" | jq
```{{exec}}
