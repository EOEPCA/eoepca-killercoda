As ususal in this tutorial, we will use the EOEPCA Deployment Guide scripts to help us configuring and deploying our application. 

First, we clone it in our environment:
```
git clone https://github.com/EOEPCA/deployment-guide
```{{exec}}

The Rescource Catalogue deployment scripts are available in the `resource-discovery` directory:
```
cd ~/deployment-guide/scripts/resource-discovery
```{{exec}}

Next we'll check whether the prerequisites for installing the Resource Discovery building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

This will ask a few questions about the Kubernetes cluster configuration and check if all the necessary prerequirements are installed. 

First, we choose th `http` scheme since we are not using certificates and encryption for our tutorial:
```
http
```{{exec}}

We choose the nginx ingress controller:
```
nginx
```{{exec}}

We enter the top-level domain for our EOEPCA services:
```
eoepca.local
```{{exec}}

The storage class is already configured in our Kubernetes cluster and selected as default for our EOEPCA deployment, we don't want to change it:
```
no
```{{exec}}

We also do not need automatically generated certificates or indeed any certificates at all for our tutorial:
```
no
```{{exec}}

Now, since in our tutorial we decided not to use certficates, we can ignore the message:
> `Cert-Manager is not installed in the cluster.`
