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

we now move to the Processing Building Block specific configuration. We use the general domain and storage class

```
no
no
```{{exec}}
