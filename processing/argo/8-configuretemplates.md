
## Configure Argo for ZOO Integration

Before we configure ZOO, we need to set up Argo with two crucial components required by the `zoo-argowf-runner` based on its documentation.

**1. Create the WorkflowTemplate**

The runner doesn't execute jobs directly; it uses a pre-defined `WorkflowTemplate` as a blueprint. We must create it in the `argo` namespace.

```bash
k create namespace test
kubectl apply -f examples/workflow-template.yaml -n test
```{{exec}}

**2. Create the Authentication Token**

Modern Kubernetes doesn't automatically create token secrets. We must create one manually so the ZOO service can authenticate with the Argo API. We'll also create the necessary RBAC `Role` and `RoleBinding` to allow this.

```bash
k create namespace processing

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argo
  namespace: processing
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: argo-workflow-creator-clusterrole
rules:
  - apiGroups: ["argoproj.io"]
    resources: ["workflows", "workflowtemplates", "clusterworkflowtemplates"]
    verbs: ["create", "get", "list", "watch"]
  - apiGroups: [""]
    resources: ["workflows"]
    verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argo-workflow-creator-binding
subjects:
  - kind: ServiceAccount
    name: argo
    namespace: processing
roleRef:
  kind: ClusterRole
  name: argo-workflow-creator-clusterrole
  apiGroup: rbac.authorization.k8s.io
EOF
---
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: argo-server-token
  namespace: processing
  annotations:
    kubernetes.io/service-account.name: argo
type: kubernetes.io/service-account-token
EOF
```{{exec}}

Now that Argo is fully prepared, we can proceed with configuring ZOO.


---

```
kubectl get secret argo-server-token -n processing -o jsonpath='{.data.token}' | base64 --decode
```{{exec}}

Then add it to the `wfToken` field in the `generated-values.yaml` file.