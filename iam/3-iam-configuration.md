In addition to the core platform configuration, there is additonal information required to fully tailor the deployment of the IAM building block to a target platform environment.

The following command runs a script `configure-iam.sh`{{}} that prompts for the information required to tailor the IAM.

Before running the script, in order that the tutorial environment is able to successfully proxy browser access to the Keycloak service, we need to preemptively override the `KEYCLOAK_HOST`{{}} variable to the external hostname exposed by the tutorial to access Keycloak.

```bash
export KEYCLOAK_HOST="$(port="$(grep auth /tmp/assets/killercodaproxy | awk '{print $1}')" ; sed "s#http://PORT#$port#" /etc/killercoda/host )"
echo "External Keycloak host: ${KEYCLOAK_HOST}"
```{{exec}}

Now we can run the configuration script for the IAM building block, which will inherit this override:

```bash
bash configure-iam.sh
```{{exec}}

For this tutorial we define some values that are consistent with the local tutorial environment:<br>
_Select the provided values to inject them into the terminal prompts_

> NOTE that some of the previosly answered questions are repeated - in which case the existing value can be accepted.

* `INGRESS_HOST`{{}} already set: `no`{{exec}}
* Storage Class for PERSISTENT `ReadWriteOnce`{{}} data: `local-path`{{exec}}
* Keycloak realm: `eoepca`{{exec}}
    _Name of the realm to create in Keycloak_
* Automated certificate issuance is not required: `no`{{exec}}
* IAM Management client ID: `iam-management`{{exec}}
    _ID for the OIDC client to be used for Keycloak management via Crossplane._
* OPA client ID: `opa`{{exec}}
    _ID for the OIDC client to be used by the Open Policy Agent service._
* Username for the tutorial Test User: `eoepcauser`{{exec}}
* Username for the tutorial Admin User: `eoepcaadmin`{{exec}}
* Password for the tutorial users: `eoepcapassword`{{exec}}

The script will also generate some passwords to be injected into the deployment.

As before, the outcomes are saved into the file `~/.eoepca/state`{{}}.

```
cat ~/.eoepca/state
```{{exec}}

These variables are used to configure the IAM helm chart for deployment. The values file `generated-values.yaml`{{}} has been created to support the deployment of the helm chart.

```
ls -l generated-values.yaml
```{{exec}}
