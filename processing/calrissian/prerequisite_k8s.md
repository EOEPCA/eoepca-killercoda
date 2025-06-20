a kubernetes cluster, with some minimal constraints, such as the availability of an ingress controller to expose the EOEPCA building block interfaces, DNS entries to map the EOEPCA interface endpoints and certificates to provide SSL support is required by EOEPCA components

Here for simplicity, we will use the basic nginx ingress controller, static DNS entries and no SSL support.

To check the Kubernetes cluster is properly installed, run

```
kubectl get -n ingress-nginx pods
```{{exec}}

which should return an `ingress-nginx-controller`{{}} pod, and try to access the storage and data processing endpoints with

```
curl -s -S http://zoo.eoepca.local
```{{exec}}

which should show you the DNS is configured correctly, even if the call returns a `404 Not Found`{{}} nginx error page, expected as we did not install our processing services yet.
