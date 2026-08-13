As usual for EOEPCA, we will use the [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/eoepca-2.1/) scripts to help us in configuring and deploying our application.

First, we download and uncompress the **eoepca-2.1** version of the EOEPCA Deployment Guide, to which this tutorial refers:

```
curl -L https://github.com/EOEPCA/deployment-guide/tarball/eoepca-2.1 | tar zx --transform 's|^EOEPCA[^/]*|deployment-guide|'
```{{exec}}

The Rescource Discovery deployment scripts are available in the `resource-discovery` directory:
```
cd deployment-guide/scripts/resource-discovery
```{{exec}}

Now we need to understand our pre-requisites. In general EOEPCA Building Blocks will require as a minimum pre-requisite a Kubernetes cluster, with an ingress controller to expose the EOEPCA building block interfaces and DNS entries to map the EOEPCA interface endpoints. Building Blocks which expose APIs for modifying data, such as adding entries to the resource catalogue, also require some form of authentication and authorization.

This tutorial uses the IAM Building Block and Keycloak for access control and the APISIX ingress controller for its OIDC integration with Keycloak.

You can also install the Resource Discovery Building Block as a read-only catalogue, in which case the IAM Building Block is not required. You might then use the Resource Registration Building Block to bulk import (meta)data.

Next we need to check the specific Resource Discovery BB prerequisites for installing the Resource Discovery building block are met. The Deployment Guide scripts provide a dedicated script for this task:
```
bash check-prerequisites.sh
```{{exec}}

The pre-requisites should already be met. You can see the running components with

```
kubectl get pods -A
```{{exec}}

which produces output similar to this

```
NAMESPACE           NAME                                                              READY   STATUS      RESTARTS   AGE
crossplane-system   crossplane-749859cbb9-xhmqf                                       1/1     Running     0          12m
crossplane-system   crossplane-contrib-function-auto-ready-ad152c878e1d-7b44868dkbv   1/1     Running     0          11m
crossplane-system   crossplane-contrib-function-environment-configs-96b084abc3tgdpb   1/1     Running     0          11m
crossplane-system   crossplane-contrib-function-python-5265eb0f3ec4-7f64df5bdfrqs7r   1/1     Running     0          11m
crossplane-system   crossplane-rbac-manager-6775d59dcd-v6nlh                          1/1     Running     0          12m
crossplane-system   provider-helm-97e4d1e72f3f-55f4fc88d9-fmtmc                       1/1     Running     0          11m
crossplane-system   provider-keycloak-fb422faeed8f-68dfdcfc46-kqpln                   1/1     Running     0          10m
crossplane-system   provider-kubernetes-f6665ef36536-8c9c64d75-c586p                  1/1     Running     0          11m
crossplane-system   provider-minio-7af4d9157ece-bd749d7b-rxq8h                        1/1     Running     0          11m
iam                 eoepca-realm-6bpwg                                                0/1     Completed   0          2m39s
iam                 iam-keycloak-operator-0                                           1/1     Running     0          6m50s
iam                 iam-keycloak-operator-operator-577969c5d8-2nrds                   1/1     Running     0          10m
iam                 iam-opa-744fbb8c8f-g45qd                                          1/1     Running     0          10m
iam                 iam-opal-client-66c8d4db74-vwbmn                                  1/1     Running     0          10m
iam                 iam-opal-pgsql-67cdb94c6b-hrlbj                                   1/1     Running     0          10m
iam                 iam-opal-server-7f4cdf96d5-bxsqg                                  1/1     Running     0          10m
iam                 iam-postgresql-0                                                  1/1     Running     0          10m
ingress-apisix      apisix-5888d7f968-5xj7p                                           1/1     Running     0          13m
ingress-apisix      apisix-ingress-controller-d8c984676-9kpb5                         2/2     Running     0          13m
kube-system         coredns-5fc55ccb8c-9tjc2                                          1/1     Running     0          13m
kube-system         local-path-provisioner-546dfc6456-grplw                           1/1     Running     0          14m
```

APISIX has already been deployed and configured to use *.eoepca.local hostnames without TLS. Keycloak has been deployed and an `eoepca` realm imported into it. We will use the Crossplane Keycloak provider later to create roles and users able to write to the resource catalogue.
