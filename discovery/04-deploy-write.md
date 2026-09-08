With the read-only Resource Catalogue service deployed, we can now deploy the writable service. This is the same software talking to the same database instance but with different configuration and a different URL, to which we apply access control.

First we configure the IAM by

* Creating an OIDC client registration with Keycloak which will be used by the ingress configuration for the writable catalogue.
* Creating a role in Keycloak, records_editor, which will be allowed to modify the catalogue.
* Creating a resource-catalogue-admin group which has this role and adding our demonstration user, eoepcauser, to it.

This is done by creating Crossplane resources using the output of the deployment scripts:

```
kubectl apply -f generated-iam.yaml
```{{exec}}

You should be able to see the created client and group with these commands:

```
kubectl get client.openidclient.keycloak.m.crossplane.io -A
kubectl get group.group.keycloak.m.crossplane.io -A
```{{exec}}

Both of these should show as ready or become ready quickly.

The writable instance needs access to the database for which we supply credentials:

```
kubectl apply -f generated-db-secret.yaml
```{{exec}}

Next, we deploy the software using the same Helm chart as for the read-only instance but with slightly different configuration:

```
helm upgrade -i resource-catalogue-protected eoepca-dev/rm-resource-catalogue \
  --values generated-protected-values.yaml \
  --version 2.1.0-dev2 \
  --namespace resource-discovery \
  --create-namespace
```{{exec}}

And we create the ingress for the service, configuring into it the OpenID Connect client and OPA authorization policy:

```
kubectl apply -f generated-protected-ingress.yaml
```{{exec}}


Now we wait for the pods to start.

```
while ! kubectl wait --for=condition=Ready --all=true -n resource-discovery pod --timeout=1m &>/dev/null; do
  sleep 10
  echo "Waiting for Resource Discovery readiness"
done

echo -e "\nResource Discovery is READY"
```{{exec}}

Once deployed, the writable STAC API is served at `http://resource-catalogue-protected.eoepca.local`{{}}. Unauthenticated requests are redirected to Keycloak instead of being served:

```
curl -s -o /dev/null -w "%{http_code}\n" http://resource-catalogue-protected.eoepca.local/
```{{exec}}

This returns `302`{{}}, the redirect to the login page.

We can now validate both the read-only and the writable catalogue with the provided script `validation.sh`{{}}

```
bash validation.sh
```{{exec}}

Opening the writable catalogue in a browser shows the protection in action. Follow [this link]({{TRAFFIC_HOST1_83}}): APISIX sends you to Keycloak, where you log in as `eoepcauser`{{}} / `eoepcapassword`{{}} and grant access to the `resource-catalogue` client, after which the catalogue pages are served (come back here afterwards, the tutorial is still not over).
