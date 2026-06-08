
EODAG comes pre-configured with many data providers and product types. Let's explore what's available.

### List All Product Types

To see all available product types (collections):

```

eodag list --no-fetch

```{{exec}}

This shows the product types that EODAG knows about, along with the providers that offer them.

### Filter by Provider

List product types available from a specific provider, such as Copernicus Data Space:

```

eodag list --provider cop_dataspace --no-fetch

```{{exec}}

Or from Earth Search (AWS):

```

eodag list --provider earth_search --no-fetch

```{{exec}}

### Filter by Platform

List product types from a specific satellite platform:

```

eodag list --platform SENTINEL2 --no-fetch

```{{exec}}

### Filter by Sensor Type

List products by sensor type (more reliable than filtering by processing level):

```

eodag list --sensorType OPTICAL --no-fetch

```{{exec}}

### Discover New Product Types

EODAG can fetch providers to discover additional product types that aren't in its default configuration:

```

eodag discover -p earth_search --storage /tmp/earth_search_products.json

```{{exec}}

View the discovered products:

```

cat /tmp/earth_search_products.json | python3 -m json.tool | head -50

```{{exec}}

### Understanding Providers

EODAG supports many providers including:
- **cop_dataspace**: Copernicus Data Space Ecosystem
- **earth_search**: Element 84's Earth Search on AWS
- **planetary_computer**: Microsoft Planetary Computer
- **usgs**: USGS Earth Explorer
- **peps**: CNES PEPS platform

Each provider may require different credentials and offer different subsets of product types.
