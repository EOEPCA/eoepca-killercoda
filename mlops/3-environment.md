The second part is the configuration for the MLOps basic environment.

First we need to point our MLOps environment to the installed gitlab and the Killercoda host address 

```
cat <<EOF >> ~/.eoepca/state
export GITLAB_URL={{TRAFFIC_HOST1_8080}}
export PATH_BASED_ROUTING=true
EOF
```{{exec}}

To do so, we can run the configuration script below. It will prompt you to set up the MLOps building block's key configuration:

```bash
bash configure-mlops.sh
```{{exec}}

the script will prompt you for the top-level domain for our EOEPCA services and the storage class to use for data persistence. Both have been configured in the step below, and we do not need to update them

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
