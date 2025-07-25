Our processing service relies on a generic, reusable Argo `WorkflowTemplate`. This template is designed to handle the boilerplate of running CWL-based workflows, including staging input data from S3 and pushing results back to S3.

First, let's get back to our home directory and clone the template's repository.

```bash
cd ..
git clone https://github.com/EOEPCA/zoo-argo-wf-workflow-template.git
cd zoo-argo-wf-workflow-template
```{{exec}}

Just like before, this repository is configured to be deployed with Skaffold. It will create a `WorkflowTemplate` resource named `argo-cwl-runner-stage-in-out` in the `argo` namespace.

Let's deploy it.

```bash
skaffold run
```{{exec}}

We can quickly verify that the template was created successfully.

```bash
kubectl get wftmpl -n ns1
```{{exec}}

You should see `argo-cwl-runner-stage-in-out` in the list. 

* **Automates Data Staging**: It automatically adds steps to fetch input data from S3 before your job starts.
* **Executes the CWL**: It uses a tool called **Calrissian** to run your CWL application on Kubernetes.
* **Handles Results**: After your job finishes, it automatically collects the outputs, logs, and usage reports and pushes them back to S3.

By using this template, you can focus on writing your science logic in a standard CWL file and let the template handle all the complex data orchestration with Argo.


TODO: expand on the template's features and how it works.