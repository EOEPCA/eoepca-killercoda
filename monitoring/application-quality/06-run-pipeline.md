
A pipeline is a sequence of analysis tools run against an application's source code. Each tool is a
containerised CWL sub-workflow, and the whole pipeline is executed on Kubernetes by Calrissian.

### Look at the pipeline we are going to run

The built-in **Python pipeline** (id `6`{{}}) clones a Git repository and analyses its Python code
with Bandit, Flake8, Pylint and Ruff:

```
curl -sS -H "Authorization: Bearer $AQ_TOKEN" "$AQ_URL/api/pipelines/6/" | jq
```{{exec}}

Note the `quality_rules`{{}}: expressions over the issue counts collected from the tools. They decide
whether a run passes.

### Execute it against a real repository

We analyse the EOEPCA Application Package Validation tool, a small public Python repository:

```bash
RUN=$(
  curl -sS -X POST "$AQ_URL/api/pipelines/6/runs/" \
    -H "Authorization: Bearer $AQ_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"parameters": {"clone_subworkflow": {"clone": {"repo_url": "https://github.com/EOEPCA/app-package-validation", "repo_branch": "main"}}}}'
)
export RUN_ID=$(echo "$RUN" | jq -r '.id')
echo "$RUN" | jq
```{{exec}}

The same thing can be done from the portal: **Pipelines** → the execute icon (a lightning bolt) on
the pipeline → fill in the repository URL → **Execute Pipeline**.

### Watch it run

Each run gets its own Kubernetes namespace, named after the run id. Calrissian runs there as a job,
and starts one pod per analysis step:

```
kubectl get pods -n applicationqualitypipeline-$RUN_ID
```{{exec}}

Run that again after a few seconds to see the step pods come and go. Open **Analysis Pipelines Executions** in the
portal to follow the same run: it shows each stage's status and the execution timeline.

Check the run itself. It moves from `starting`{{}} to `running`{{}} and finally to `succeeded`{{}};
image downloads can make the first run take several minutes:

```
curl -sS -H "Authorization: Bearer $AQ_TOKEN" "$AQ_URL/api/pipelines/6/runs/$RUN_ID/" | jq
```{{exec}}

Repeat that command until the status is `succeeded`{{}} and four job reports have been collected.
The run resources are removed after completion, so the pod listing above becomes empty.

### Read the results

Each tool posts its findings back to the API as a job report, with a digest counting the issues it
found by severity:

```
curl -sS "$AQ_URL/api/pipelines/6/runs/$RUN_ID/jobreports/" | jq
```{{exec}}

The run aggregates those counts and evaluates the pipeline's quality rules against them:

```
curl -sS -H "Authorization: Bearer $AQ_TOKEN" "$AQ_URL/api/pipelines/6/runs/$RUN_ID/" | jq '.digest'
```{{exec}}

The counts add up across the four tools. `digest_quality`{{}} gives the quality verdict. The
`pass`{{}} rule requires no errors, no critical issues, no security issues and no warnings, and the
verdict depends on the findings for the selected revision. A `succeeded`{{}} execution can still
fail its quality rules. Style-only findings (`convention`{{}}, `info`{{}}) do
not fail the rule on their own.

The full report of each tool is kept as well. Ruff's findings, for example, name the rule, the file
and the suggested fix:

```
curl -sS "$AQ_URL/api/pipelines/6/runs/$RUN_ID/jobreports/?name=ruff" | jq '.[0].output[0]'
```{{exec}}

In the portal, the **Reports** tab shows the same reports per run and per tool.

### Inspect execution resources

Application Quality also stores Calrissian's execution resource report:

```
curl -sS -H "Authorization: Bearer $AQ_TOKEN" "$AQ_URL/api/pipelines/6/runs/$RUN_ID/" | jq '.usage_report'
```{{exec}}

`children`{{}} lists every step of the workflow - the clone, each analysis tool, and the steps that
digest and save its report - with timings and CPU, memory and disk accounting. The top level
summarises the run. These figures are execution accounting, rather than sampled CPU or memory
utilisation; very short steps can have zero durations and null time-based totals.
