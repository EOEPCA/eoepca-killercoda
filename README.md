# EOEPCA Tutorials

This repository provides a suite of tutorials that introduce the deployment and usage of the EOEPCA Building Blocks.

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
>   * ref. localcoda configuration `VIRT_ENGINE=sysbox`
>   * see [Run localcoda using sysbox](https://github.com/spinto/localcoda/blob/main/docs/ADVANCED_CONFIG.md#run-using-sysbox)
> * on **Apple Silicon Macs** the backend images must be built locally for arm64 — the published images are amd64-only and do not work under emulation (see [macOS notes](#macos-notes))

> **Setup Alternative - `codavm`**
> 
> The setup included here establishes a 'native' localcoda setup. Alternatively you can use `codavm` that provides a pre-packaged virtual machine including docker, sysbox, localcoda and eoepca-killercoda - deployed and ready for execution of the tutorials.
> 
> `codavm` relies upon Vagrant to provision the VM, with an appropriate provider such as VirtualBox or libvirt.
> 
> See [here](https://github.com/rconway/codavm) for details of [`codavm`](https://github.com/rconway/codavm).

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

Enter the tutorial directory.

```bash
cd eoepca-killercoda
```

Set the environment to reference the localcoda deployment, by creating a `.env` file with the following content, replacing `<my-ip>` with your machine's IP address (e.g. `192.168.1.10`)...

```bash
export LOCALCODA_ROOT="../localcoda"
export EXT_DOMAIN_NAME=".<my-ip>.nip.io"
```

> On Linux, `EXT_DOMAIN_NAME` is optional (localcoda auto-detects a nip.io address). On macOS it is required — see [macOS notes](#macos-notes). Setting it also makes the tutorials reachable from other devices on your network.

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
find . -name index.json -exec dirname {} \;
```

### macOS notes

* **A modern bash is required** — macOS ships bash 3.2, but the localcoda backend and some helper scripts (`open.sh`, `restart.sh`) use bash 4+ features. Install it with `brew install bash` (the scripts use `#!/usr/bin/env bash`, so the Homebrew version is picked up via `PATH`). If `which bash` still shows `/bin/bash` afterwards (symptom: `bad substitution` errors from `backend_run.sh`), Homebrew's directory isn't early enough in your `PATH` — fix it with:
  ```bash
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  ```
  and open a new terminal.
* **`EXT_DOMAIN_NAME` must be set in `.env`** — localcoda's nip.io auto-detection relies on `ip` or `hostname -i`, neither of which is available on macOS. Get your IP with:
  ```bash
  ipconfig getifaddr en0
  ```
  and set e.g. `export EXT_DOMAIN_NAME=".192.168.1.10.nip.io"`.
* **Apple Silicon** — the localcoda backend images published on Docker Hub are linux/amd64 only, so they run emulated, and the k3s backend image used by all tutorials in this repository does not work under emulation: the emulated containerd reports `seccomp is not supported`, so the Kubernetes system pods never start. Fix: build the images natively for arm64 from the localcoda repository ([spinto/localcoda#6](https://github.com/spinto/localcoda/pull/6)):
  ```bash
  cd ../localcoda/backend/bin && /opt/homebrew/bin/bash ./backend_images_build.sh
  ```
  (macOS ships bash 3.2; the build script needs bash ≥ 4, hence the Homebrew bash.) The locally built `spinto/localcoda-docker-*:latest` images take precedence over Docker Hub — verified working end-to-end with the discovery tutorial. Note the EOEPCA application images deployed *inside* a tutorial may themselves be amd64-only; those then run emulated within k3s.
* nip.io addresses need internet DNS; if your router has DNS-rebind protection the names may not resolve — use a public DNS server (e.g. 8.8.8.8) in that case.

### Other commands

In addition to `run.sh` these additional helpers are provided:

* `list.sh` - list running tutorials
* `stop.sh` - stop a tutorial
* `open.sh` - open the UI for a tutorial in your browser
* `restart.sh` - restart a tutorial
* `console.sh` - connect to a terminal within a running tutorial
