we are now asked to determine which nodes will run the processing jobs.

This is an important field as it will allow to allocate different portions of the Kubernetes cluster to the data processing jobs executed via the OGC API Process interface.

For this demo, we use a very basic requirement for the nodes running processing, which is the nodes with linux.

```
kubernetes.io/os
linux
```{{exec}}

the S3 endpoint that we will use for storing the output is the local S3 storage, which was already configured in the pre-requisites, so we do not need to update its configuration (endpoint, access key, secret key and region)

```
no
no
no
no
```{{exec}}

we will also use the same S3 storage for stagein and stageout, so we reply again to no to the next question

```
no
```{{exec}}

now, the script is asking if we want to enable authentication via Open ID connect.

This is strongly recommended for the processing API, as otherwise every user will be able to deploy processing and run it.

Anyway, for this basic demo, we will disable it by responding false to the question.

```
false
```{{exec}}

we now have a set of configuration values for our building block deployment available, you can check them with

```
less generated-values.yaml
```{{exec}}

NOTE: Press `q`{{exec}} to exit when you are done inspecting the file, and we can move to the next step
