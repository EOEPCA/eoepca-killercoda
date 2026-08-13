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
helm upgrade -i resource-catalogue-protected eoepca/rm-resource-catalogue \
  --values generated-protected-values.yaml \
  --version 2.1.0 \
  --namespace resource-discovery \
  --create-namespace
```{{exec}}

And we create the ingress for the service, configuring into it the OpenID Connect client and OPA authorization policy:

```
kubectl apply -f generated-protected-ingress.yaml
```{{exec}}


Now we wait for the pods to start. To automatically wait until it is read you can run:

```
kubectl wait --for=condition=Available -n resource-discovery deployment/resource-catalogue-protected-service
while [[ `curl -s -o /dev/null -w "%{http_code}" "http://resource-catalogue-protected.eoepca.local/stac"` != 302 ]]; do sleep 1; done
```{{exec}}

Once deployed, the Resource Discovery STAC API should be accessible at `http://resource-catalogue-protected.eoepca.local`{{}}

We can validate it with the provided script `validation.sh`{{}}

```
bash validation.sh
```{{exec}}

and also have a look at the catalogue web interface from [this link]({{TRAFFIC_HOST1_83}}) (come back here afterwards, the tutorial is still not over).
