before proceeding with the building block deployment, we need first to configure it. We can do so with the help of the EOEPCA dployment guide configuration script, by running

```
bash configure-oapip.sh
```{{exec}}

The script will start with the general EOEPCA configuration.

For the demo deployment we are not generating certificates, so we will restrict ourself to the http scheme

```
http
```{{exec}}

As said in the previous chapter, we will use the nginx ingress in this demo deployment

```
nginx
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

we now move to the Processing Building Block specific configuration, starting with the general Zoo configuration.

We do not need to update domain and storage class, as we can use the standard ones

```
no
no
```{{exec}}

the S3 endpoint that we will use for storing the output is the local S3 storage, which was already configured in the pre-requisites, so we do not need to update its configuration (endpoint, access key, secret key and region)

```
no
no
no
no
```{{exec}}

For this test, we will not use the EOEPCA Workspace, but store results into a generic object storage. Thus we reply false to the next question

```
false
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

we completed the Zoo general configuration and we will proceed in the next step with the processing engine specific configuration
