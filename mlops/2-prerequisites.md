
## Prerequisites and Initial Configuration

Clone deployment scripts:

```bash
git clone https://github.com/EOEPCA/deployment-guide.git -b killercoda-jh-changes

cd deployment-guide/scripts/mlops
```{{exec}}

### Get your Killercoda temporary URL from the top corner 
1. Traffic / Ports
2. Custom Ports
3. 30080 
4. Access
5. Copy the URL excluding the https://

You should get something like
```
XXXXXXXXXXX-XX-XXX-X-XXX-30080.spca.r.killercoda.com
```

Now run

```bash
export INGRESS_HOST=<YOUR UNIQUE KILLERCODA URL>
```

We will also supply you with the Gitlab and secret for this demonstration.

```bash
export PATH_BASED_ROUTING=true
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