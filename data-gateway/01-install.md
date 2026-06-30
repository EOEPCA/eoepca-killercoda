EODAG is distributed as a Python package. We will install it in a virtual environment so that its dependencies remain isolated from the tutorial VM's system Python.

### Prepare Python

Install the small set of system tools used throughout the tutorial:

```
apt-get update -qq
apt-get install -y -qq python3 python3-pip python3-venv curl jq > /dev/null 2>&1

python3 -m venv ~/venv
source ~/venv/bin/activate
pip install --upgrade pip
```{{exec}}

The shell prompt now starts with `(venv)`. Commands such as `python`, `pip`, and `eodag` will use the isolated environment under `~/venv`.

### Install EODAG

Install the tested EODAG version with its optional server dependencies. The `[server]` extra adds the packages required by the STAC API used later in the tutorial.

```
pip install "eodag[server]==3.10.2"
```{{exec}}

### Verify the Installation

Ask the installed command to report its version:

```
eodag version
```{{exec}}

The expected version is `3.10.2`.

Now display the command-line help:

```
eodag --help
```{{exec}}

The commands we will use are:

- `list` — inspect the product types already known to EODAG;
- `discover` — ask a provider for additional product-type definitions;
- `search` — search provider catalogues and serialise the results as GeoJSON;
- `serve-rest` — expose EODAG through a local STAC API.

EODAG also provides `download`. We will inspect download and asset links in this workshop, but not transfer a complete EO product because those files can be several gigabytes.

### Create the User Configuration

On its first useful command, EODAG creates a user configuration file. Run a short listing to trigger that initialisation:

```
eodag list --no-fetch 2>/dev/null | head -5
```{{exec}}

Inspect the beginning of the generated file:

```
head -30 ~/.config/eodag/eodag.yml
```{{exec}}

The configuration is organised by provider. It can hold provider priorities, search settings, download settings, and credentials. We do not add credentials in this tutorial: EODAG automatically excludes providers that require search authentication and can fall back between the remaining public search endpoints.
