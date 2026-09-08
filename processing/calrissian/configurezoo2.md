Select the Calrissian execution engine:

```
calrissian
```{{exec}}

Choose the node label used to schedule processing jobs. This example uses Linux nodes:

```
kubernetes.io/os
linux
```{{exec}}

Inspect the generated Helm values:

```
less generated-values.yaml
```{{exec}}

Press `q`{{exec}} to exit.

Run the deployment guide prerequisite checks using the configuration you just saved:

```
bash check-prerequisites.sh
```{{exec}}
