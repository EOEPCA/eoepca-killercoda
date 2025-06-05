
## Prerequisites and Initial Configuration

Ensure the following are available (already provided in this environment):

- Kubernetes cluster (v1.28+)
- Helm 3
- APISIX ingress controller
- cert-manager
- MinIO S3-compatible storage
  
Clone deployment scripts:

```bash
git clone https://github.com/EOEPCA/deployment-guide.git -b killercoda-jh-changes

cd deployment-guide/scripts/mlops
```{{exec}}

Get your Killercoda temporary URL from the top corner -> Traffic / Ports -> Custom Ports -> 30080 -> Access.

You should get something like
XXXXXXXXXXX-XX-XXX-X-XXX-30080.spca.r.killercoda.com

Now run

```bash
export INGRESS_HOST=<YOUR UNIQUE KILLERCODA URL>
export PATH_BASED_ROUTING=true
```

We will also supply you with the Gitlab and secret for this demonstration.

```bash
export GITLAB_URL="https://gitlab.test.eoepca.org"
export GITLAB_APP_ID="281ed7984b08581e2adec68db96fb207a715c3216ba1f4ca6b0706c483d52269"
```{{exec}}

```bash
export GITLAB_APP_SECRET=""
```

Run the prerequisites check:

```bash
bash check-prerequisites.sh <<EOF
http
nginx
no
local-path
no
EOF
```{{exec}}