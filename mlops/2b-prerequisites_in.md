Another pre-requisite for the EOEPCA installation is the availability of an [Ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/), allowing [Ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/) to expose the services deployed by EOEPCA. To this Ingress controller, the DNS names of the services needs to be allocated.

In this sandbox environment, in order to reduce resource consumptions, we will not use an Ingress controller but access the services directly from their local node port. We will then use the proxy and DNS provided by the sandbox environment to access our specific services. In summary, when we will complete the deployment, we will be able to access the service via:

- GitLab at: [{{TRAFFIC_HOST1_80}}]({{TRAFFIC_HOST1_8080}})
- SharingHub at: [{{TRAFFIC_HOST1_30226}}]({{TRAFFIC_HOST1_30226}})
- Mlflow at: [{{TRAFFIC_HOST1_30336}}]({{TRAFFIC_HOST1_30336}})

Note also that, with this solution, we will use directly GitLab authentication within the MLOps Building Block, while the default EOEPCA integration relies on the [APISIX](https://apisix.apache.org/) ingress controller for integrating authentication within the system.
