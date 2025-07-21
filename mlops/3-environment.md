It is now time to configure our EOEPCA Building Block environment. We will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/) scripts to help us configuring and deploying our application.

First, we download and uncompress the **eoepca-2.0-rc1b** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/killercoda-jh-changes | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

The MLops deployment scripts are available in the `mlops` directory:
```
cd deployment-guide/scripts/mlops
```{{exec}}

We need now to configure the environment variable. These are stored into a file at `~/.eoepca/state`{{}} and for most installation are created via an helper script.

EOEPCA in general uses sub-domain based routing for the different Building Blocks. In our sandbox this is not possible, as we do not support wildcard DNS entries and we have only one single DNS address allocated to the Ingress, thus we need to enable path based routing and use the DNS entry provided by the sandbox environment as single DNS entry. To do so, we can create the appropriate configuration variables via

```
cat <<EOF >> ~/.eoepca/state
export PATH_BASED_ROUTING=true
export INGRESS_HOST="`sed -e 's|^https://||' -e 's|PORT|30226|' /etc/killercoda/host`"
EOF
```{{exec}}

We need also to provide the path to the Gitlab sub-compoenet installation. In this tutorial we are not deploying Gitlab inside the Kubernetes cluster but using an external gitlab installed into th same sandbox machine. We need then to specify its link via

```
cat <<EOF >> ~/.eoepca/state
export GITLAB_URL="`sed -e 's|PORT|8080|' /etc/killercoda/host`"
EOF

We can now run the MLOps environment configuration script via

```bash
bash configure-mlops.sh
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

Now the script will prompt you for the top-level domain for our EOEPCA services and the storage class to use for data persistence. Both have been configured in the step below, and we do not need to update them

```
no
no
```{{exec}}

the script will then ask you about the details of the object storage. Also this is already pre-configured, so we do not need to update it

```
no
no
no
no
```{{exec}}

the script will now ask for the S3 buckets to use for the SharingHub and for the MLFlow, we can use the default ones

```
mlopbb-sharinghub
mlopbb-mlflow-sharinghub
```{{exec}}

the script now created the `mlflow/generated-values.yaml`{{}} and `sharinghub/generated-values.yaml`{{}} configuration values which we will use to deploy the software in the next steps

it also created some secrets, which we need now to apply

```bash
bash apply-secrets.sh
```{{exec}}
