As said before, EOEPCA Building Blocks are built on a micro-services approach, with several Docker images composing the different micro-services orchestrated by the platform. It can be then useful in production to have your own local container registry, and allow faster access to images and lower startup times.

EOEPCA recommends using [Harbor](https://goharbor.io/), an open-source container registry, to manage images for applications on the platform, including those from the Application Hub or running within the Processing building block.

Key features of Harbor include:
- Role-Based Access Control (RBAC): Control access to images based on user roles.
- Vulnerability Scanning: Detect vulnerabilities in images.
- Image Signing: Verify the authenticity of images.
- Audit Logs: Track operations for compliance.
- Replication: Sync images across multiple Harbor instances.

As usual, we will deploy Harbor using scripts provided in the EOEPCA Deployment Guide.

Let's check for prerequisites first. At this point all of them should be met:
```
cd ~/deployment-guide/scripts/container-registry
bash check-prerequisites.sh
```{{exec}}

Run the configuration script, answering `no` to all questions since these values are already set correctly:
```
bash configure-container-registry.sh
no
no
no
```{{exec}}

Now add the repository:
```
helm repo add harbor https://helm.goharbor.io
helm repo update harbor
```{{exec}}

And deploy Harbor into our Kubernetes cluster
```
helm upgrade -i harbor harbor/harbor \
  --version 1.7.3 \
  --values generated-values.yaml \
  --namespace harbor \
  --create-namespace
```{{exec}}

We wait until the all pods in the `harbor` namespace are ready:
```
kubectl --namespace harbor wait pod --all --timeout=10m --for=condition=Ready
```{{exec}}

We can now run the script `validation.sh` to see if our Harbor deployment works fine:
```
bash validation.sh
```{{exec}}

Again, since we do not have web browser access to our Harbor instance, we will use a combination of command line tools to perform some operations on Harbor:
- create a project
- push and pull images
- list the content of repositories

For this, we need the Harbor CLI tool [`harbor`](https://github.com/goharbor/harbor-cli). We also need to reconfigure Docker so that it trusts our Harbor registry which otherwise doesn't have a valid certificate. Both requirements have already been installed and/or configured and both are not really necessary in a production environment where Harbor is supposed to have a signed valid TLS certificate.

First we must login to our Harbor registry from Docker, with the password in the variable `HARBOR_ADMIN_PASSWORD` saved in `~/.eoepca/state`.
```
source ~/.eoepca/state
docker login -u admin -p "${HARBOR_ADMIN_PASSWORD}" harbor.eoepca.local
```{{exec}}

We pull an image from DockerHub, tag it and push it to Harbor. Typically, local images created by users will be stored that way.
```
docker pull alpine:latest
docker tag alpine:latest harbor.eoepca.local/library/alpine:latest
docker push harbor.eoepca.local/library/alpine:latest
```{{exec}}

Now we delete the local images:
```
docker image rm alpine:latest
docker image rm harbor.eoepca.local/library/alpine:latest
docker image ls
```{{exec}}

Now we pull the image from our Harbor registry:
```
docker pull harbor.eoepca.local/library/alpine:latest
docker image ls
```{{exec}}

Let's check with Harbor CLI the content of the registry. This can typically be done using the web interface.
- First we must log in to Harbor:
  ```
  harbor login -u admin -p ${HARBOR_ADMIN_PASSWORD} harbor.eoepca.local
  ```{{exec}}
- List projects:
  ```
  harbor project list
  ```{{exec}}
- List repositories in the project `library`:
  ```
  harbor repo list library
  ```{{exec}}
- List artifacts in the repo `library/alpine`:
  ```
  harbor artifact list library/alpine
  ```{{exec}}
- Show details of the artifact (image) `alpine:latest`, earlier pushed to the registry with Docker, with output in YAML:
  ```
  harbor artifact view library/alpine:latest -o yaml
  ```{{exec}}
- Delete artifact `alpine:latest` from repo:
  ```
  harbor artifact delete library/alpine:latest
  ```{{exec}}
- Delete `alpine` repo from project:
  ```
  harbor repo delete library/alpine
  ```{{exec}}

  
