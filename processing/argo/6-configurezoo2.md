we are configuring the Argo Workflows processing engine, so we need to select it

```
argo
```{{exec}}

For the Argo processing engine, we need now to configure the Kubernetes namespace where Argo will run the processing workflows.

For this demo, we will use the `argo` namespace. Note that Argo Workflows must be installed in this namespace for the processing to work.

```
argo
```{{exec}}

we now have a set of configuration values for our building block deployment available, you can check them with

```
less generated-values.yaml
```{{exec}}

NOTE: Press `q`{{exec}} to exit when you are done inspecting the file, and we can move to the next step