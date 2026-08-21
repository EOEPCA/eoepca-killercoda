We can now deploy the Resource Registration building block's API service. 

We deploy the software via helm, using the configuration values generated in the previous step.

```
helm upgrade -i registration-api eoepca/registration-api \
  --version 2.1.0 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-api/generated-values.yaml
```{{exec}}


And we create the ingress for our newly created Resource Registration API service to make it available, using the configuration file generated automatically in the previous step.

```
kubectl apply -f registration-api/generated-ingress.yaml
```{{exec}}

Finally, we must register the registration service as a Keycloak client so that it can authenticated and be authorized by the Resource Discovery BB:

```
source ~/.eoepca/state
kubectl apply -f generated-iam.yaml
kubectl wait --for=condition=Ready client.openidclient.keycloak.m.crossplane.io/${RESOURCE_REGISTRATION_IAM_CLIENT_ID} -n iam-management --timeout=60s
```{{exec}}

Now we wait for the Resource Registration pods to start. This may take some time, especially in this demo environment. To automatically wait until all service to are ready and the catalogue responds correctly you can run:

```
while [[ `curl -s -o /dev/null -w "%{http_code}" "http://registration-api.eoepca.local/"` != 200 ]]; do sleep 1; done
```{{exec}}

Once deployed, the Resource Registration OGC Processes API should be accessible at `http://registration-api.eoepca.local`{{}}
Or via the [Killercoda proxy]({{TRAFFIC_HOST1_82}})


You can also check the status of the Kubernetes resources directly

```
kubectl get all -n resource-registration
```{{exec}}

We can also see the provided registration processes via

```
curl -s http://registration-api.eoepca.local/processes | jq
```{{exec}}


Or have a look at in the browser at [this link]({{TRAFFIC_HOST1_82}}) (come back here afterwards, the tutorial is not over).
