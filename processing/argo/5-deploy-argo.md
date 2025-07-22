## Deploy Argo Workflows

Before we can configure Zoo to use Argo as its execution engine, we must first install Argo Workflows into our Kubernetes cluster. This will create the necessary Custom Resource Definitions (CRDs) and controllers that manage the execution of our processing jobs.

First, we create the namespace where Argo and its workflows will live:

```
kubectl create namespace argo
```{{exec}}

Next, we apply the official installation manifest from the Argo Project. This will deploy all the required components.

```
curl -L -o argo-install.yaml https://github.com/argoproj/argo-workflows/releases/download/v3.5.15/install.yaml
```{{exec}}

3. Edit the File to Disable TLS 📝
Now, open the argo-install.yaml file you just downloaded in a text editor (like nano, vim).

Search for the text name: argo-server.

In that section, find the spec.template.spec.containers block.

Add the line - --secure=false to the args: list, as shown below.

It should look like this when you're done:

```
spec:
  template:
    spec:
      containers:
      - args:
        - server
        - --secure=false ## <-- ADD THIS LINE
        image: quay.io/argoproj/argocli:v3.5.15
```

```
kubectl apply -n argo -f ./argo-install.yaml
```{{exec}}
Now, we need to wait for the Argo services to start. This may take a minute or two.

```
kubectl -n argo wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

Once all the pods are in a `Ready` state, our Argo Workflows engine is installed and ready to receive jobs from the OGC API Process interface. You can see the running components with:

```
kubectl get pods -n argo
```{{exec}}
