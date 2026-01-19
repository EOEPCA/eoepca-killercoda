
Let's start by installing EODAG and its dependencies.

# Install Python and pip
```
apt-get update -qq
apt-get install -y -qq python3 python3-pip python3-venv curl jq > /dev/null 2>&1

python3 -m venv ~/venv
source ~/venv/bin/activate
pip install --upgrade pip
```{{exec}}

## Install EODAG

EODAG is available via pip. We'll install it with the server extras to enable the STAC REST API functionality:

```
pip install eodag[server]
```{{exec}}

This installs the core EODAG library plus the dependencies needed to run it as a STAC server.

## Verify Installation

Check that EODAG is installed correctly:

```
eodag version
```{{exec}}

### View Available Commands

EODAG provides several CLI commands:

```
eodag --help
```{{exec}}

The main commands are:
- `list`: List supported product types/collections
- `search`: Search for EO products
- `download`: Download products from search results
- `discover`: Fetch providers to discover available collections
- `serve-rest`: Start a STAC-compliant REST API server

## Initial Configuration

The first time EODAG runs, it creates a configuration file at `~/.config/eodag/eodag.yml`. Let's trigger this:

```
eodag list --no-fetch 2>/dev/null | head -5
```{{exec}}

You can view the generated configuration template:

```
cat ~/.config/eodag/eodag.yml | head -30
```{{exec}}

This file is where you would add credentials for providers that require authentication for searching or downloading.