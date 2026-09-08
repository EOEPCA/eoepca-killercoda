Deploy the **[EOEPCA Workspace](https://eoepca.readthedocs.io/projects/workspace/en/latest/)** building block, create a workspace and use its object storage and Datalab development environment.

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
  A REST API and web UI for creating and deleting workspaces, backed by two Kubernetes Custom Resources it manages per workspace (below).

* **Storage Controller (provider-storage)**<br>
  A Kubernetes Custom Resource responsible for creating and managing S3-compatible buckets (e.g., MinIO, AWS S3, or OTC OBS).

* **Datalab Controller (provider-datalab)**<br>
  A Kubernetes Custom Resource used to deploy persistent VSCode-based environments with direct object-storage access, either directly on Kubernetes or within a vCluster.

* **Identity & Access (Keycloak)**<br>
  Manages user and team identities, enabling role-based access control and granting permissions to specific Datalabs and storage resources.

## **Crossplane**

The Workspace BB uses Crossplane to create and manage these resources, which requires deploying:

* **Dependencies** - CSI-RClone for storage mounting and the Educates framework for workspace environments.
* **Pipelines** - template and provision each workspace's storage, Datalab configuration, and environment settings.
* **Provider Configurations** - the Crossplane Providers this BB uses: MinIO, Kubernetes, Keycloak, and Helm.

---

## **Assumptions**

Before we start, you should note that this tutorial assumes a generic knowledge of EOEPCA prerequisites (Kubernetes, Object Storage, etc...) and some tools installed on your environment (gomplate, minio client, etc...). If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Prerequisites</a> tutorial.

## **Wait for Readiness**

Before proceeding, wait for the prerequisite services to be ready:

```
kubectl wait --for=condition=Ready pod --all -A --timeout=10m -l 'app!=keycloak-realm-import'
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
