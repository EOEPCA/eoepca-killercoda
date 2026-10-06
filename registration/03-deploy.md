We can now deploy the Resource Registration building block's API service. 

We deploy the software via helm, using the configuration values generated in the previous step.

```
helm repo add eoepca https://eoepca.github.io/helm-charts
helm repo update eoepca
# TODO - remove this when catalogue and reg-api have a stable release
helm repo add eoepca-dev https://eoepca.github.io/helm-charts-dev
helm repo update eoepca-dev

helm upgrade -i registration-api eoepca-dev/registration-api \
  --version 2.1.0-dev2 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-api/generated-values.yaml
```{{exec}}


And we create the ingress for our newly created Resource Registration API service to make it available, using the configuration file generated automatically in the previous step.

```
kubectl apply -f registration-api/generated-ingress.yaml
```{{exec}}

Finally, we must register the harvester as a Keycloak client - even though the target STAC API doesn't itself require authentication, the generic STAC-catalog harvester used later always requests an access token before it writes to the catalogue:

```
source ~/.eoepca/state
kubectl apply -f generated-iam.yaml
kubectl wait --for=condition=Ready client.openidclient.keycloak.m.crossplane.io/${RESOURCE_REGISTRATION_IAM_CLIENT_ID} -n iam-management --timeout=60s
```{{exec}}

Now we wait for the Registration API to start and answer requests. This may take some time, especially in this demo environment:

```
curl -sf -o /dev/null --retry 30 --retry-delay 10 --retry-all-errors \
  "http://registration-api.eoepca.local/" \
  && echo "Registration API is serving requests"
```{{exec}}

Once deployed, the Resource Registration OGC Processes API should be accessible at `http://registration-api.eoepca.local`{{}}
Or via the [Killercoda proxy]({{TRAFFIC_HOST1_82}})


You can also check the status of the Kubernetes resources directly

```
kubectl get all -n resource-registration
```{{exec}}

We can also list the processes the Registration API provides:

```
curl -s http://registration-api.eoepca.local/processes | jq '.processes[].id'
```{{exec}}

`register`{{}} and `deregister`{{}} add and remove resources, and `pyeomp-record-validate`{{}} checks a record against the EOEPCA Metadata Profile.


Or have a look at in the browser at [this link]({{TRAFFIC_HOST1_82}}) (come back here afterwards, the tutorial is not over).
