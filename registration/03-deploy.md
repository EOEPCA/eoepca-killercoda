We can now deploy the Resource Registration building block. 


# Registration API

We deploy the software via helm, using the configuration values generated in the previous step.

```
helm upgrade -i registration-api eoepca/registration-api \
  --version 2.0.0-dev12 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-api/generated-values.yaml
```{{exec}}


And we create the ingress for our newly created Resource Registration API service to make it available, using the configuration file generated automatically in the previous step.

```
kubectl apply -f registration-api/generated-ingress.yaml
```{{exec}}

Now we wait for the Resource Registration pods to start. This may take some time, especially in this demo environment. To automatically wait till all service to are ready you and the catalogue responds correctly you can run:

```
while [[ `curl -s -o /dev/null -w "%{http_code}" "http://registration-api.eoepca.local/stac"` != 200 ]]; do sleep 1; done
```{{exec}}

Once deployed, the Resource Registration OGC Processes API should be accessible at `http://registration-api.eoepca.local`{{}}

We can validate it with the provided script `validation.sh`{{}}

```
bash validation.sh
```{{exec}}

We can also see the provided registration processes via

```
curl -s http://registration-api.eoepca.local/processes | jq
```{{exec}}


Or have a look at in the browser at [this link]({{TRAFFIC_HOST1_82}}) (come back here afterwards, the tutorial is not over).
