We have our platform, our workflow template, our application package and our test runner.

Let's execute the workflow.

We'll run our test using the `nose2` test runner, which will discover and execute the `test.py` script we just created.

```bash
nose2
```{{exec}}

You will see some output status updates from the `zoo-argowf-runner`. The runner will submit the job to Argo and wait for it to complete. The whole process should take about 10 minutes.