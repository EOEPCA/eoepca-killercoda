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

We can inspect the template to see how it works.

```bash
kubectl get wftmpl argo-cwl-runner-stage-in-out -n ns1 -o yaml
```{{exec}}

This `WorkflowTemplate` is a blueprint designed to automate running a CWL-based analysis. 

It is designed to handle three distinct operational stages:

**Data Staging**
It manages the transfer of data to and from S3 object storage. Inputs are fetched before the job begins, and all resulting outputs, logs and usage reports are archived back to S3 upon completion.

**CWL Execution**
It uses a tool called Calrissian to interpret the CWL definition and run the analysis as a series of jobs on the Kubernetes cluster.

**Results**
The template is configured to capture logs and outputs from both successful and failed runs.
