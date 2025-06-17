In addition to the core platform configuration, there is additonal information required to fully tailor the deployment of the IAM building block to a target platform environment. The following command runs a script that prompts for the information required to tailor the IAM.

```bash
bash configure-iam.sh
```{{exec}}

For this tutorial we define some values that are consistent with the local tutorial environment:<br>
_Select the provided values to inject them into the terminal prompts_

> NOTE that some of the previosly answered questions are repeated - in which case the existing value can be accepted.

* `INGRESS_HOST`{{}} already set: `n`{{exec}}
* `STORAGE_CLASS`{{}} already set: `n`{{exec}}
* Keycloak realm: `eoepca`{{exec}}<br>
  Name of the realm to create in Keycloak
* OPA client ID: `opa`{{exec}}<br>
  ID for the OIDC client to be used by the Open Policy Agent service.
* Identity API client ID: `identity-api`{{exec}}<br>
  ID for the OIDC client to be used by the Identity API service.

The script will also generate some passwords to be injected into the deployment.

As before, the outcomes are saved into the file `~/.eoepca/state`{{}}.

```
cat ~/.eoepca/state
```{{exec}}

These variables are used to configure the IAM helm chart for deployment. The values file `generated-values.yaml`{{}} has been created to support the deployment of the helm chart.

```
ls -l generated-values.yaml
```{{exec}}
