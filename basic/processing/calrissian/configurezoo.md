before proceeding with the building block deployment, we need first to configure it. We can do so with the help of the EOEPCA dployment guide configuration script, by running

```
bash configure-oapip.sh
```{{exec}}

The script will start with the general EOEPCA configuration.

As said in the previous chapter, we will use the nginx ingress in this demo deployment

```
nginx
```{{exec}}

for the demo deployment we are not generating certificates, so we will restrict ourself to the http scheme

```
http
```{{exec}}

as a domain, we use eoepca.local, which is mapped to the local machine in this demo

```
eoepca.local
```{{exec}}

our storage class was already setup to 'standard' in the step before, so we do not need to update it

```
no
```{{exec}}

as we have http only services, we do not need certificate generation (which anyway would not work in this demo environment)

```
no
```{{exec}}

We now move to the Processing Building Block specific configuration. We use the general domain and storage class

```
no
no
```{{exec}}

We are now asked to determine which nodes will run the processin jobs. This is an important field as it will allow to allocate different portions of the Kubernetes cluster to the data processing jobs executed via the OGC API Process interface. For this demo, we use a very basic requirement, which is the nodes with linux.

```
kubernetes.io/os
linux
```{{exec}}

The S3 endpoint that we will use for storing the output is 

```
no
no
no
no
```{{exec}}

We will also use the same S3 storage for stagein and stageout, so we reply again to no to the next question

```
no
```{{exec}}

Now, the script is asking if we want to enable authentication via Open ID connect. This is strongly recommended for the processing API, as otherwise every user will be able to deploy processing and run it. Anyway, for this basic demo, we will disable it by responding false to the question.

```
false
```{{exec}}

We now have a set of configuration values for our building block deployment available, you can check them with

```
less generated-values.yaml
```{{exec}}

