Now that you have configured the IAM environment and applied the necessary secrets, it's time to deploy the IAM components using Helm charts. This will set up Keycloak for identity management and OPA with OPAL for policy enforcement. An additional Keycloak host (resulting in an extra ingress host) is added so that Keycloak is accessible both from your browser, from outside the tutorial environment, and from within the tutorial environment.

> The release-2.1 IAM chart is not published as a stable release yet - it's currently only
> available as a pre-release from the `eoepca-dev` chart repository.

```bash
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev
helm upgrade -i iam eoepca-dev/iam-bb \
  --version 2.1.0-dev13 \
  --namespace iam --create-namespace \
  --values generated-values.yaml \
  --set iam.keycloak.hosts="{${KEYCLOAK_HOST},auth.eoepca.local}"
```{{exec}}

Now you can check the status of the IAM deployment:

```bash
kubectl get pods -n iam
```{{exec}}

Wait for all IAM pods to be `Running`{{}}, which may take ~5 minutes to complete:

```bash
kubectl -n iam rollout status \
  deployment.apps/iam-opal-server \
  deployment.apps/iam-opal-pgsql \
  deployment.apps/iam-opal-client \
  deployment.apps/iam-opa \
  statefulset.apps/iam-postgresql \
  statefulset.apps/iam-keycloak-operator \
  deployment.apps/iam-keycloak-operator-operator
```{{exec}}

> DO NOT proceed until the above command completes, indicating that the IAM pods are now running.

## Check Keycloak Service

Once all pods are running and ready, you can check the Keycloak service discovery endpoint...

> There may still be a short delay until the IAM services are ready and responding to requests.

```bash
curl -k http://auth.eoepca.local/realms/master/.well-known/openid-configuration | jq
```{{exec}}

## Check Keycloak UI

> NOTE that the Keycloak service takes some time to accept connections following startup.

At this point we can check access to the [Keycloak Web UI]({{TRAFFIC_HOST1_90}}) - using the `admin`{{}} credentials defined in the `~/.eoepca/state`{{}} file.

```bash
grep KEYCLOAK_ADMIN_ ~/.eoepca/state
```{{exec}}

## Check the EOEPCA Realm

A realm called `eoepca` has been created by a background Job created by the Helm chart and can be checked by querying the OpenID configuration endpoint for the realm.

```bash
curl -k http://auth.eoepca.local/realms/eoepca/.well-known/openid-configuration | jq
```{{exec}}

If this does not return data for the realm (a long JSON document) then wait a little longer for the job to complete or inspect `kubectl get job -n iam eoepca-realm`.

Note that a user called `eoepcaadmin` (or the username given to the configuration script) has been pre-created and in a real environment you should replace this with an individual admin account for each system administrator.
