EODAG is distributed as a Python package. We will install it in a virtual environment so that its dependencies remain isolated from the tutorial VM's system Python.

### Prepare Python

Create and activate an isolated Python environment:

```
python3 -m venv ~/venv
source ~/venv/bin/activate
```{{exec}}

The shell prompt now starts with `(venv)`. Commands such as `python`, `pip`, and `eodag` will use the isolated environment under `~/venv`.

### Install EODAG

Install the tested EODAG version with the `[all-providers]` extra, which pulls in the dependencies needed by every built-in provider plugin:

```
pip install "eodag[all-providers]==4.7.2"
```{{exec}}

### Verify the Installation

Ask the installed command to report its version:

```
eodag version
```{{exec}}

The expected version is `4.7.2`.

Now display the command-line help:

```
eodag --help
```{{exec}}

The commands we will use are:

- `list` — inspect the collections already known to EODAG;
- `discover` — ask a provider for additional collection definitions;
- `search` — search provider catalogues and serialise the results as GeoJSON;
- `download` — retrieve product data.

A complete Sentinel-2 product is around one gigabyte, so in the final step we download a single small asset rather than a whole scene.

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
