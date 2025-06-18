we are configuring the Calrissian Kubernetes processing engine, so we need to select it

```
calrissian
```{{exec}}

For the Calrissian processing engine, we need now to conigure how Calrissian will determine which Kubernetes nodes it will run the processing jobs.

This is an important field as it will allow to allocate different portions of the Kubernetes cluster to the data processing jobs executed via the OGC API Process interface.

For this demo, we use a very basic requirement for the nodes running processing, which is the nodes with linux.

```
kubernetes.io/os
linux
```{{exec}}

we now have a set of configuration values for our building block deployment available, you can check them with

```
less generated-values.yaml
```{{exec}}

NOTE: Press `q`{{exec}} to exit when you are done inspecting the file, and we can move to the next step
