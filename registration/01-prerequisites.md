We will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us in configuring and deploying our application.

First, we download and uncompress the **eoepca-2.0-TBD** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
#curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.0-TBD | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
git clone https://github.com/EOEPCA/deployment-guide
```{{exec}}


## Resource Discovery BB

The Resource Discovery BB must be installed for the Resource Registration BB to work, so we do that first here. Follow the Resource Discovery tutorial for a full description. Unlike the Resource Discovery tutorial, here we use the apisix ingress controller because nginx is not compatible with the Resource Registration BB's support for OIDC.

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
  --version 2.0.0-rc2 \
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
