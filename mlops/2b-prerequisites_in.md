a kubernetes cluster, with some minimal constraints, such as the availability of an ingress controller to expose the EOEPCA building block interfaces, DNS entries to map the EOEPCA interface endpoints and certificates to provide SSL support is required by EOEPCA components

Here for simplicity, we will use the basic nginx ingress controller, static DNS entries and no SSL support, as described in the [EOEPCA pre-requisites tutorial](../pre-requisites).

To check the Kubernetes cluster is properly installed, run

```
kubectl get -n ingress-nginx pods
```{{exec}}

which should return an `ingress-nginx-controller`{{}} pod.

This ingress is accessible from the sandbox environment via a reverse proxy, avaiable at

```
{{TRAFFIC_HOST1_80}}
```{{}}

At this time, if you try o access this URL, you will get a 404 "Not Found" error, as we did not deploy the Building Block yet.

Note that the address above is a single DNS address for all the services hosted in the Kubernetes cluster, so for all the EOEPCA services. The EOEPCA services will need then to use path-based routing to properly route the requests to the different sub-components of the EOEPCA MLOps Building Block.

At last, we will not deploy in this tutorial the Gitlab sub-component of the MLOps Building Block within the Kubernetes cluster, but use an external gitlab instance. This one is available at

```
{{TRAFFIC_HOST1_8080}}
```{{}}

In summary, the SharingHub and MLOps components will be accessible via the Ingress controller at port 80, while the Gitlab will be accessible directly via the port 8080.
