For the Kubernetes cluster itself there is one strong requirement: pods must be able to run as root. This is required for the deployment of some of the main EOEPCA components services.

Note that, for security, in production, cluster's security policies shall be defined to allow running containers as root only in the namespaces where the main EOEPCA components services run, not in the namespaces hosting, for example, execution of user applications and processing tasks.

Here, in our sandbox environment, we can simply check whether in our cluster a pod with root privileges can be created:
```
cat <<EOF | kubectl apply -f - 
apiVersion: v1
kind: Pod
metadata:
  name: root-check
spec:
  containers:
    - name: busybox
      image: busybox
      command: ["sleep", "3600"]
      securityContext:
        allowPrivilegeEscalation: false
        runAsUser: 0
  restartPolicy: Never
EOF
```{{exec}}

We wait until our `root-check`{{}} pod is ready:
```
kubectl wait pod root-check --timeout=10m --for=condition=Ready
```{{exec}}

We check whether it is running as root:
```
kubectl exec -it root-check -- id -un
```{{exec}}

If the output is `root`{{}}, it is confirmed that our pod is running with root privileges.

Now we can delete the pod:
```
kubectl delete pod root-check
```{{exec}}

Next, considering the Wildcard DNS, we have not way to set this up in our sandbox environment, but we can use the /etc/hosts and the internal Kubernetes CoreDNS service to bind some DNS names to our cluster. For example, with the code below, we can map the `test.eoepca.local`{{}} domain to the sandbox Kubernetes cluster IP `172.30.1.2`{{}}. Note that the need for CoreDNS setup below is to make this address accessible also from the internal Kubernetes cluster network

```
WEBSITES="test.eoepca.local minio.eoepca.local console-minio.eoepca.local harbor.eoepca.local"
echo "172.30.1.2 $WEBSITES" >> /etc/hosts
kubectl get -n kube-system configmap/coredns -o yaml > kc.yml
sed -i "s|ready|ready\n        hosts {\n          172.30.1.2 $WEBSITES\n          fallthrough\n        }|" kc.yml
kubectl apply -f kc.yml && rm kc.yml && kubectl rollout restart -n kube-system deployment/coredns
```{{exec}}

We can check this works by trying to access this address.

```
curl -v http://test.eoepca.local
```{{exec}}

as you can see, we cannot connect to the server, as we did not deploy any Ingress controller for our Kubernetes cluster (we will do in the next step), but the `test.eoepca.local`{{}} address is resolved correctly
