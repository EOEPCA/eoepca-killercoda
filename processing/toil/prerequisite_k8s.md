A Kubernetes cluster is required by EOEPCA components, together with an ingress controller to expose their interfaces and DNS entries that map the service endpoints.

For simplicity, we use the nginx ingress controller, static DNS entries, and no TLS support, as described in the [EOEPCA prerequisites tutorial](../pre-requisites).

Check that the Kubernetes ingress controller is installed:

```
kubectl get -n ingress-nginx pods
```{{exec}}

The command should return an `ingress-nginx-controller` pod in `Running` status.

Now test the processing hostname:

```
curl --silent --show-error --include http://zoo.eoepca.local | head
```{{exec}}

At this point, `404 Not Found` is expected. It confirms that DNS and nginx are working, but there is no ZOO-Project ingress route yet.
