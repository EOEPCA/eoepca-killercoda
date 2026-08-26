We will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, we clone the **release-2.1** branch of the EOEPCA Deployment Guide, to which this tutorial refers:

<!-- TODO(release-2.1): once the eoepca-2.1 tag is published, revert this step to the tarball
     download used elsewhere: curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.1
     | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|' -->
```
git clone --branch release-2.1 --depth 1 https://github.com/EOEPCA/deployment-guide.git
```{{exec}}


## Resource Discovery BB

For this tutorial the Resource Discovery BB is installed to provide a registration target for the Resource Registration BB. So first we deploy the Resource Discovery catalogue service - follow the Resource Discovery tutorial for a full description. We need both the read-only and protected (writable) Resource Discovery services as the Resource Registration BB will use the writable endpoint to submit changes to the catalogue.

The Resource Registration BB relies upon the APISIX ingress controller for its OIDC integration with Keycloak. Thus, the Resource Discovery BB is deployed here configured for ingress via APISIX.

```
cd deployment-guide/scripts/resource-discovery

echo "n
local-path
no" | bash check-prerequisites.sh

echo "yes" | bash configure-resource-discovery.sh

# Resource Discovery 2.1.0 has not yet been promoted to the stable `eoepca` chart
# repository, so for now we use `eoepca-dev`, which carries the latest pre-release chart.
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev

# Read-only service
helm upgrade -i resource-discovery eoepca-dev/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.1.0-dev2 \
  --namespace resource-discovery \
  --create-namespace

kubectl apply -f generated-ingress.yaml

# Read-write service
kubectl apply -f generated-iam.yaml
kubectl apply -f generated-db-secret.yaml

helm upgrade -i resource-catalogue-protected eoepca-dev/rm-resource-catalogue \
  --values generated-protected-values.yaml \
  --version 2.1.0-dev2 \
  --namespace resource-discovery \
  --create-namespace

kubectl apply -f generated-protected-ingress.yaml
```{{exec}}

The Resource Discovery BB may take several minutes to start. You can begin installing the Resource Registration BB whilst this happens, but if you wish to wait then run this

```
kubectl wait --for=condition=Available -n resource-discovery deployment/resource-catalogue-service deployment/resource-catalogue-protected-service
while [[ `curl -s -o /dev/null -w "%{http_code}" "http://resource-catalogue.eoepca.local/stac"` != 200 ]]; do sleep 1; done
bash validation.sh
```{{exec}}


## Other Resource Registration BB Pre-requisites

The Resource Registration deployment scripts are available in the `resource-registration` directory:
```
cd ~/deployment-guide/scripts/resource-registration
```{{exec}}

The Resource Registration BB requires some shared pre-requisites with the Resource Discovery BB, such as Kubernetes cluster, ingress controller, Crossplane and IAM BB, which have already been installed.

Next we need to check the specific Resource Registration BB prerequisites are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

Now, all the pre-requisites should be met.
