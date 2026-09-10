# EOEPCA Tutorials

## Release 2.1: quick start

You need two repositories: **eoepca-killercoda** contains the tutorials, and **Localcoda** runs them with instructions and a terminal in your browser. You do not need a separate Kubernetes cluster.

Use a Linux x86-64 machine or VM with Docker installed and accessible to your account (`docker ps` should work). The build also needs Git, curl, jq and zstd. On Ubuntu or Debian, install these with:

```bash
sudo apt-get update
sudo apt-get install -y git curl jq zstd
```

**Download both repositories and build the Localcoda images:**

```bash
mkdir -p eoepca-tutorials
cd eoepca-tutorials
git clone --depth=1 https://github.com/spinto/localcoda.git
git clone --branch eoepca-2.1 --depth=1 https://github.com/EOEPCA/eoepca-killercoda.git
cd localcoda
bash backend/bin/backend_images_build.sh -E docker
cd ../eoepca-killercoda
```

Allow time for the first image build to finish. This uses Localcoda's default Docker runtime; no separate frontend image is needed to run a single tutorial. For Workspace, see the Sysbox instructions below.

**Start a tutorial**, for example Data Access:

```bash
export LOCALCODA_ROOT="../localcoda"
bash run.sh data-access
```

Open the URL printed by the command in your browser. Wait for the environment setup to finish in the tutorial terminal, then follow the pages to deploy and use the Building Block. If running on a remote server, your browser must be able to reach its address and the printed port; see **External Access** below.

---

## Running on localcoda

> **NOTES**
> 
> * localcoda relies upon `docker` for execution, which must already be installed and usable for the current user
> * the `Workspace` tutorial must be run using `sysbox` (rather than `docker`)
>   * ref. locacoda configuration `VIRT_ENGINE=sysbox`
>   * see [Run localcoda using sysbox](https://github.com/spinto/localcoda/blob/main/docs/ADVANCED_CONFIG.md#run-using-sysbox)

### Setup

Create a local root directory for the tutorials and localcoda environment.

```bash
mkdir -p eoepca-tutorials
cd eoepca-tutorials
```

Clone the `localcoda` repository.

```bash
git clone --depth=1 --single-branch https://github.com/spinto/localcoda
```

Clone this `eoepca-killercoda` repository.

```bash
git clone --depth=1 --single-branch https://github.com/EOEPCA/eoepca-killercoda
```

Enter the tutoral directory.

```bash
cd eoepca-killercoda
```

Set the environment to reference the localcoda deployment.

```bash
cat <<EOF >.env
export LOCALCODA_ROOT="../localcoda"
export EXT_DOMAIN_NAME=".<my ip>.nip.io"  # Optional: for external access
EOF
```

### Running a tutorial

Run a tutorial using the script `./run.sh` using the path to the required tutorial.

```bash
./run.sh <path-to-tutorial>
```

For example, to run the `Resource Discovery` tutorial.

```bash
./run.sh discovery
```

You should see output like...

```
Starting containter lc-bk-4acc41fd4ccc4ed4b5a38a97682d0f1c...
Waiting for lc-bk-4acc41fd4ccc4ed4b5a38a97682d0f1c to start...
Your tutorial is ready and accessible from:
http://4acc41fd4ccc4ed4b5a38a97682d0f1c-lc.c0a800e9.nip.io:23682/
```

Open the provided link in your browser to connect with the tutorial.

The available tutorial directories can be found using

```bash
find -name index.json -printf "%h\n"
```

### External Access

To access tutorials via an external IP, set `EXT_DOMAIN_NAME` in your `.env`:
```bash
export EXT_DOMAIN_NAME=".<your external ip>.nip.io"
```

### Other commands

In addition to `run.sh` these additional helpers are provided:

* `list.sh` - list running tutorials
* `stop.sh` - stop a tutorial
* `open.sh` - open the UI for a tutorial in your browser
* `restart.sh` - restart a tutorial
* `console.sh` - connect to a terminal within a running tutorial
