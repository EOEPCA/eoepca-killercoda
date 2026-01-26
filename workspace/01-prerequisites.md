As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, we download and uncompress the **eoepca-2.0-TBD** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-rc3 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

The Workspace deployment scripts are available in the `workspace` directory:
```
cd deployment-guide/scripts/workspace
```{{exec}}

The EOEPCA Deployment Guide uses scripts to facilitate the deployment. The scripts are highly configurable to allow adaption to the target deployment environemnt, and so they request user input to gather information. This deployment information is maintained by the scripts in the state file `~/.eoepca/state`.

The tutorial startup scripts have already pre-configured a number of aspects of the deployment to fit with the constraints of the tutorial environment, including:
* use of `http` instead of `https`
* `eoepca.local` as the 'platform' domain
* use of the Storage Classes `local-path` (ReadWriteOnce) and `standard` (ReadWriteMany)
* configuration of Keycloak and Minio services

```bash
cat ~/.eoepca/state
```{{exec}}

In general EOEPCA Building Blocks will require as a minimum prerequisite a Kubernetes cluster, with an ingress controller to expose the EOEPCA building block interfaces and DNS entries to map the EOEPCA interface endpoints. The Workspace BB integrates with the Identity & Access BB in conjuction with the APISIX ingress controller to provide authentication and authorization services.

We can check the specific prerequisites for installing the Workspace building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

All the prerequisites should be met.
