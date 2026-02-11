# EOEPCA Tutorials

This respository provides a suite of tutorials that introduce the deployment and usage of the EOEPCA Building Blocks.

The EOEPCA tutorials can be run either directly on [Killercoda](https://killercoda.com/eoepca), or locally using [localcoda](https://github.com/spinto/localcoda).

> Due to limitations of the Killercoda cloud service, not all tutorials can be run in this environment. In such cases, then localcoda should be used.

## Running on Killercoda

Visit the [EOEPCA Tutorials](https://killercoda.com/eoepca) on Killercoda.

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
cat <<EOF >.envrc
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

To access tutorials via an external IP, set `EXT_DOMAIN_NAME` in your `.envrc`:
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
