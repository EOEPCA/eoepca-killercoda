To make our trainings simple we have decided not to use encryption for the network traffic, therefore the Cert-Manager is not actually required for these tutorials. However, in production, HTTPS should be used and valid certificates generated and assigned to all the EOEPCA Building Blocks.

This is what [Cert-Manager](https://cert-manager.io/) does, and in this Basics training we will install it anyway to show how it can be deployed.

One important thing is that in this sandbox we will set it up with internal ClusterIssuer (a local CA) instead of the default (and recommended) LetsEncrypt since in our sandbox we have no possibility to use the latter (no access from the Internet to our cluster).

Let's deploy the Cert-Manager then:
```
helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack
helm upgrade -i cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --version v1.16.1 \
  --set crds.enabled=true
```{{exec}}

Then, there is an already provided script in the Deployment Guide to set up local CA and ClusterIssuer. The ClusterIssuer name is `eoepca-ca-clusterissuer` which we already configured in our EOEPCA settings in the beginning of this tutorial.
```
pushd ~/deployment-guide/scripts/internal-tls
bash setup-internal-tls.sh
popd
```{{exec}}

We can check if our ClusterIssuer is present:
```
kubectl --namespace cert-manager get clusterissuer -o wide
```{{exec}}

For details how these local items are created or how to set up Cert-Manager with LetsEncrypt please refer to the section [Certificates Management](https://eoepca.readthedocs.io/projects/deploy/en/latest/prerequisites/tls/) in the Deployment Guide.
