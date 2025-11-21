
A Kubernetes cluster with some minimal constraints is required by EOEPCA components, such as the availability of an ingress controller to expose the EOEPCA building block interfaces, DNS entries to map the EOEPCA interface endpoints, and certificates to provide SSL support.

Here for simplicity, we'll use the basic nginx ingress controller, static DNS entries and no SSL support.

To check the Kubernetes cluster is properly installed, run:

```bash
kubectl get -n ingress-nginx pods
```

This should return an `ingress-nginx-controller` pod. Let's also verify the namespace for our OpenEO deployment exists:

```bash
kubectl create namespace openeo
```

Try to access the OpenEO endpoint (which isn't deployed yet):

```bash
curl -s -S http://openeo.eoepca.local
```

This should show you the DNS is configured correctly, even if the call returns a `404 Not Found` nginx error page (expected as we haven't installed our OpenEO services yet).

Let's also check we have sufficient resources for Dask workers:

```bash
kubectl get nodes -o wide
kubectl describe nodes | grep -A 5 "Allocated resources"
```

The Dask backend will dynamically spawn worker pods, so we need adequate CPU and memory available in our cluster.