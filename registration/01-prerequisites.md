We will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, we download and uncompress the **eoepca-2.0-TBD** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
#curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-TBD | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
git clone https://github.com/EOEPCA/deployment-guide
```{{exec}}


## Resource Discovery BB

For this tutoral the Resource Discovery BB is installed to provide a registration target for the Resource Registration BB. So first we deploy the Resource Discovery catalogue service - follow the Resource Discovery tutorial for a full description.

The Resource Registration BB relies upon the APISIX ingress controller for its OIDC integration with Keycloak. Thus, the Resource Discovery BB is deployed here configure for ingress via APISIX.

```
cd deployment-guide/scripts/resource-discovery
bash check-prerequisites.sh

echo "n
local-path
no" | bash configure-resource-discovery.sh

helm repo add eoepca https://eoepca.github.io/helm-charts-dev
helm repo update

helm upgrade -i resource-discovery eoepca/rm-resource-catalogue \
  --values generated-values.yaml \
  --version 2.0.0-rc4 \
  --namespace resource-discovery \
  --create-namespace

kubectl apply -f generated-ingress.yaml
```{{exec}}

The Resource Discovery BB may take several minutes to start. You can begin installing the Resource Registration BB whilst this happens, but if you wish to wait then run this

```
while [[ `curl -s -o /dev/null -w "%{http_code}" "http://resource-catalogue.eoepca.local/stac"` != 200 ]]; do sleep 1; done
bash validation.sh
```{{exec}}


## Other Resource Registration BB Pre-requisites

The Resource Registration deployment scripts are available in the `resource-registration` directory:
```
cd ~/deployment-guide/scripts/resource-registration
```{{exec}}

The Resource Registration BB requires some shared pre-requisites with the Resource Registration BB, such as Kubernetes cluster and ingress controller, which have already been installed.

Next we need to check the specific Resource Discovery BB prerequisites are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

Now, all the pre-requisites should be met.
