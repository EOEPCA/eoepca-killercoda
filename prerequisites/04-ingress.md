An [Ingress controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/) is the system allowing [Ingresses](https://kubernetes.io/docs/concepts/services-networking/ingress/), so allowing the services deployed within a Kubernetes cluster to be accessible from outside via external endpoints.

Most ingresses work in conjunction Load Balancer, this because the Kubernetes cluster is composed by multiple nodes. The ingress will make the applications accessible from the single nodes, and all these nodes needs to be mapped by one single central entity, redirecting the external requests to the nodes. This is what a Load Balancer does. In this sandbox environment we have only one node, so we can skip a Load Balancer, but if you need to create one in your cluster you can check the [Kubernetes Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/).

Back to the Ingress, EOEPCA can be deployed with two types of Ingress controllers, the [nginx ingress controller](https://docs.nginx.com/nginx-ingress-controller/) and the [APISIX](https://apisix.apache.org/) ingress controller.

Note that most kubernetes clusters from cloud providers or from local installations (like [Rancher](https://www.rancher.com/)] will provide you already with an nginx ingree controller, while you will need to install APISIX, if required, manually.

For EOEPCA, the nginx controller can be used for most building blocks without authorization, while authorization is provided via APISIX. For details refer to the [relevant section of the EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/prerequisites/ingress/overview/)

In this sample sandbox, we can deploy the Ingress controller nginx by first add the nginx repository:
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```{{exec}}

Then install nginx ingress controller from the repository:
```
helm upgrade -i ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.ingressClassResource.default=true \
  --set controller.allowSnippetAnnotations=true \
  --set controller.hostNetwork=true
```{{exec}}

Note that the command above is tailored for this sandbox and not used for production. For production, you should follow the [Ingress Nginx Controller documentation](https://github.com/kubernetes/ingress-nginx)

We wait until the all pods in the `ingress-nginx` namespace are ready:
```
kubectl --namespace ingress-nginx wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

To test, we need first to create a sample web service which we wan to expose outside of our cluster:

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/docs/examples/http-svc.yaml
```{{exec}}

To test, we can create a test ingress for a non-existent service:
```
cat <<EOF | kubectl apply -f - 
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
    - host: test.eoepca.local
      http:
        paths:
          - pathType: Prefix
            backend:
              service:
                name: http-svc
                port:
                  number: 80
            path: /
EOF
```{{exec}}

Now we can check if our ingress works. We need first to wait some time for the ingress to be cnfigured properly, then we can attempt to connect one of the services we have configured in DNS:
```
sleep 5
curl -s -S http://test.eoepca.local
```{{exec}}

You should now see your service responding.

If instead of using nginx we want to use APISIX, which is the one required to enable authentication in the EOEPCA components, we need first to remove nginx via

```
helm uninstall -n ingress-nginx ingress-nginx
```{{exec}}

Then, to install APISIX in our sangbox, the installation can be performed with the following commands in our sandbox environent.

```
helm repo add apisix https://charts.apiseven.com
helm repo update apisix

helm upgrade -i apisix apisix/apisix \
  --version 2.9.0 \
  --namespace ingress-apisix --create-namespace \
  --set securityContext.runAsUser=0 \
  --set hostNetwork=true \
  --set service.http.containerPort=80 \
  --set apisix.ssl.containerPort=443 \
  --set etcd.replicaCount=1 \
  --set apisix.enableIPv6=false \
  --set apisix.enableServerTokens=false \
  --set ingress-controller.enabled=true
```{{exec}}

Note that, as per nginx, this APISIX installation is tailored for this sandbox and not used for production. For production, you should follow the [APISIX installation documentation](https://apisix.apache.org/docs/apisix/installation-guide/)

We wait until the all pods in the `ingress-apisix` namespace are ready:
```
kubectl --namespace ingress-apisix wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

And then we can check if our previous test ingress still works

```
curl -s -S http://test.eoepca.local
```{{exec}}

As you can see, we have a "route not found" error. This is because our old ingress was configured for nginx, while we are using APISIX now, so we need to update the ingress via

```
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test
spec:
  ingressClassName: apisix
  rules:
    - host: test.eoepca.local
      http:
        paths:
          - pathType: Prefix
            backend:
              service:
                name: http-svc
                port:
                  number: 80
            path: /
EOF
```{{exec}}

If we retry, our APISIX ingress should work now

```
curl -s -S http://test.eoepca.local
```{{exec}}

Finally, let's delete our sample ingress:
```
kubectl delete ingress/test deployment/http-svc service/http-svc
```{{exec}}

