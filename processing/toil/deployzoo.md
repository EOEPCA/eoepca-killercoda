We can now deploy our processing building block.

The building block deploys ZOO-Project, which provides the OGC API - Processes interface. When a processing request is received, ZOO-Project prepares the workflow and submits it to Toil WES. Toil then executes the application jobs through HTCondor on the HPC environment.

First, add and update the ZOO-Project Helm repository:

```
helm repo add zoo-project https://zoo-project.github.io/charts/
helm repo update zoo-project
```{{exec}}

Deploy the software using the values generated in the previous step:

```
helm upgrade --install zoo-project-dru zoo-project/zoo-project-dru \
  --version 0.10.3 \
  --values generated-values.yaml \
  --namespace processing \
  --create-namespace
```{{exec}}

We now need to wait for the ZOO-Project services to start. This can take some time in the tutorial environment:

```
kubectl -n processing wait pod --all \
  --timeout=10m \
  --for=condition=Ready
```{{exec}}

Run the deployment guide validation:

```
bash validation.sh
```{{exec}}

The OGC API - Processes interface should now be available:

```
curl --silent --show-error \
  http://zoo.eoepca.local/ogc-api/processes/ \
  | jq
```{{exec}}

If everything worked, the response contains an `echo` processing service. This is a simple built-in demonstration process. We will add our own application in the next step.

You can also explore the interface in the [Swagger UI]({{TRAFFIC_HOST1_81}}/swagger-ui/oapip/).
