
### Understanding Pipelines

A pipeline is a sequence of analysis tools that run against your code. Each tool is a containerised CWL workflow step executed by Calrissian on Kubernetes.

### Using the Web Interface to Create a Pipeline

For the full pipeline creation experience, use the web portal:

1. Navigate to **Pipelines** in the sidebar
2. Look for the pipeline called **Docker pipeline**
3. Click the **Execute button** (Looks like a lightning bolt)
4. Click **Execute Pipeline** (The **Docker image** section should be prefilled. But feel free to change it to another public image if you like)


### Monitor Execution

Switch to the **Monitoring** view to watch your pipeline run. You'll see:
- Each stage's status (pending, running, completed, failed)
- Execution timeline
- Resource usage

You can also view the pods in the `applicationqualitypipeline-1` namespace that has been created for this pipeline execution (May take a minute before you see the pods):

```
kubectl get pods -n applicationqualitypipeline-1
```{{exec}}

### View Results

Once the pipeline completes, navigate to the **Reports** tab. Here you can see the results of the pipeline.