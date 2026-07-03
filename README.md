# EOEPCA Tutorials

Please pick one of these, we have four instances running.

https://lc.tutorials.eoepca.org/
https://lc.tutorials-two.deploybox.co.uk/
https://lc.tutorials-three.deploybox.co.uk/
https://lc.tutorials-four.deploybox.co.uk/

This repository provides a suite of tutorials that introduce the deployment and usage of the EOEPCA Building Blocks.

The EOEPCA tutorials can be run either directly on [Killercoda](https://killercoda.com/eoepca), or locally using [localcoda](https://github.com/spinto/localcoda).

> Due to limitations of the Killercoda cloud service, not all tutorials can be run in this environment. In such cases, then localcoda should be used.

## Running on Killercoda

Visit the [EOEPCA Tutorials](https://killercoda.com/eoepca) on Killercoda.

## Running on localcoda

> **NOTES**
> 
> * localcoda relies upon `docker` for execution, which must already be installed and usable for the current user
> * the `Workspace` tutorial must be run using `sysbox` (rather than `docker`)
>   * ref. localcoda configuration `VIRT_ENGINE=sysbox`
>   * see [Run localcoda using sysbox](https://github.com/spinto/localcoda/blob/main/docs/ADVANCED_CONFIG.md#run-using-sysbox)
> * on **Apple Silicon Macs** the backend images must be built locally for arm64 — the published images are amd64-only and do not work under emulation (see [macOS notes](#macos-notes))

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
