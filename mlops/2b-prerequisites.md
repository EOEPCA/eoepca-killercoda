As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us configuring and deploying our application.

First, we download and uncompress the **eoepca-2.0-rc1b** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/killercoda-jh-changes | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

The MLops deployment scripts are available in the `mlops` directory:
```
cd deployment-guide/scripts/mlops
```{{exec}}

Now we need to understand our pre-requisites. In general EOEPCA Building Blocks will require as minimal pre-requisite a Kubernetes cluster, with an ingress controller to expose the EOEPCA building block interfaces and DNS entries to map the EOEPCA interface endpoints. In this tutorial, for simplicity, nginx Ingress is already installed.

We now need to setup the hostname for accessing our installation. For this, we will use the external killercoda access host.

```
cat <<EOF >>~/.eoepca/state
export INGRESS_HOST="$(echo "{{TRAFFIC_HOST1_80}}" | sed -E 's~^https?://~~;s~/.*~~')"
EOF
```{{exec}}

Next we need to check the specific Resource Discovery BB prerequisites for installing the Resource Discovery building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary pre-requirements are installed.

EOEPCA components can work with or without certificates. We choose th `http` scheme since we are not using certificates and encryption for our tutorial:
```
http
```{{exec}}

EOEPCA components can work with different Ingress services installed in your Kubernetes cluster. The default configuration uses [apisix](https://apisix.apache.org/) to provide advanced authentication and authorization. For this demo environment, we will use the simpler nginx ingress without authorization

```
nginx
```{{exec}}

The top-leve domain for our EOEPCA services is the one we have setup before, we do not need to update it.
```
no
```{{exec}}

We do not need a specific Storage Class for this component, so for this example we will use the basic storage class provided in this sandbox. Note that, in an operational environment, you should use a reliable (and possibly redundant and backed up) storage class, as this storage class will be used to store all the metadata of your data

```
local-path
```{{exec}}

We also do not need automatically generated certificates or indeed any certificates at all for our tutorial:
```
no
```{{exec}}

Now, all the pre-requisites should be met
