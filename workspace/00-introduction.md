Welcome to the **[EOEPCA Workspace](https://eoepca.readthedocs.io/projects/workspace/en/latest/)** building block tutorial!

**Workspaces** enable individuals, teams, and organisations to provision isolated, self-service environments for data access, algorithm development, and collaborative exploration — all declaratively managed on Kubernetes and orchestrated through the **Workspace REST API** or via the **Workspace Web UI**.

In this scenario, you will learn how to deploy and interact with the EOEPCA Workspace Building Block — which provides a unified environment that combines object storage, interactive runtimes, and collaborative tooling into a single Kubernetes-native platform.

---

## **What You'll Learn**

- Deploy the Workspace building block on Kubernetes
- Enable the Workspace BB for Crossplane integration
- Establish integration with IAM for sharing management
- Explore the Workspace REST API
- Create a new Workspace and explore its UI
- Connect with the Workspace object storage
- Create custom workloads in the user's vCluster

---

## **Overview**

The Workspace BB comprises the following key components:

* **Workspace API and UI**<br>
  Orchestrate storage, runtime, and tooling resources via a unified REST API by managing the underlying Kubernetes Custom Resources (CRs).

* **Storage Controller (provider-storage)**<br>
  A Kubernetes Custom Resource responsible for creating and managing S3-compatible buckets (e.g., MinIO, AWS S3, or OTC OBS).

* **Datalab Controller (provider-datalab)**<br>
  A Kubernetes Custom Resource used to deploy persistent VSCode-based environments with direct object-storage access — either directly on Kubernetes or within a vCluster — preconfigured with essential services and tools.

* **Identity & Access (Keycloak)**<br>
  Manages user and team identities, enabling role-based access control and granting permissions to specific Datalabs and storage resources.

## **Crossplane**

The Workspace BB relies upon Crossplane to manage the creation and lifecycle of the resources that deliver these capabilities. This requires the deployment of:

* **Dependencies**, including CSI-RClone for storage mounting and the Educates framework for workspace environments.
* **Pipelines**, which manage the templating and provisioning of workspace resources, including storage, datalab configurations, and environment settings.
* **Provider Configurations**, that support the usage of specific Crossplane Providers such as MinIO, Kubernetes, Keycloak, and Helm.

---

## **Assumptions**

Before we start, you should note that this tutorial assumes a generic knowledge of EOEPCA prerequisites (Kubernetes, Object Storage, etc...) and some tools installed on your environment (gomplate, minio client, etc...). If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Prerequisites</a> tutorial.

## **Wait for Readiness**

Before proceeding, wait for the prerequisite services to be ready:

```
while ! kubectl wait --for=condition=Ready --all=true -A pod --timeout=10s &>/dev/null; do
  not_ready=$(kubectl get pods -A --no-headers | awk '$3 !~ /1\/1/ {print "  " $1 "/" $2}')
  echo -e "\nWaiting for Readiness - PODS not ready ($(date -u)): \n$not_ready"
done
```{{exec}}

## **Prerequisite Services**

At this point we can check access to the web UIs of some of the prerequisite services:

> NOTE that the Keycloak service takes some time to accept connections following startup.

* [MinIO Console]({{TRAFFIC_HOST1_901}})
  * Username: `eoepca`
  * Password: `eoepcatest`
* [Keycloak]({{TRAFFIC_HOST1_82}})
  * Username: `admin`
  * Password: `eoepcatest`

The MinIO service is provisioned with an `eoepca` bucket.

The Keycloak service is provisioned with an `eoepca` realm in which there is an `iam-management` client that supports the Crossplane Keycloak Provider, and two test users `eoepcaadmin` and `eoepcauser`.
