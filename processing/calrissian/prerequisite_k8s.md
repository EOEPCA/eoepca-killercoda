This tutorial uses nginx ingress and HTTP. Check that the controller is running:

```
kubectl get -n ingress-nginx pods
```{{exec}}

Check that the processing hostname reaches nginx:

```
curl -sS http://zoo.eoepca.local
```{{exec}}

A `404 Not Found` response is expected before ZOO-Project is installed.
