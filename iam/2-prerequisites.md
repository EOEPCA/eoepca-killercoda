## Prerequisite and Initial Configuration

Before deploying the IAM components, ensure your environment is ready. This scenario provides a Kubernetes cluster (v1.28+) with **kubectl** access, **Helm 3**, and an **APISIX** ingress controller already provisioned.

## Download Deployment Scripts

First, we download and uncompress the **eoepca-2.0-TBD** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

and navigate to the deployment scripts

```
cd deployment-guide/scripts/iam
```{{exec}}

## Check IAM Prerequisites

The EOEPCA Deployment Guide uses scripts to facilitate the deployment. The scripts are highly configurable to allow adaption to the target deployment environemnt, and so they request user input to gather information. This deployment information is maintained by the scripts in the state file `~/.eoepca/state`{{}}.

The tutorial startup scripts have already pre-configured a number of aspects of the deployment to fit with the constraints of the tutorial environment, including:
* use of `http`{{}} instead of `https`{{}}
* `eoepca.local`{{}} as the 'platform' domain
* use of APISIX as the ingress controller

```bash
cat ~/.eoepca/state
```{{exec}}

In general EOEPCA Building Blocks will require as a minimum prerequisite a Kubernetes cluster, with an ingress controller to expose the EOEPCA building block interfaces and DNS entries to map the EOEPCA interface endpoints.

The IAM BB requires APISIX as the ingress controller for policy enforcement, and relies upon Crossplane for declarative Keycloak configuration via Kubernetes Custom Resources. Thus, APISIX and Crossplane have been pre-configured in this tutorial environment.

We can check the specific prerequisites for installing the Workspace building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

All the prerequisites should be met.
