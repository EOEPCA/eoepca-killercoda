EODAG ships with a catalogue of provider and product-type definitions. These definitions tell EODAG how its common search model maps onto each provider's API.

### List All Product Types

The full formatted listing is several thousand lines, so save it to a file and print a useful summary:

```
eodag list --no-fetch > /tmp/eodag-product-types.txt
printf "Known product types: "
grep -c '^\* ' /tmp/eodag-product-types.txt
sed -n '1,25p' /tmp/eodag-product-types.txt
```{{exec}}

`--no-fetch` is important here: it uses EODAG's local definitions and does not contact every remote provider. Each entry includes a product-type ID, descriptive metadata, and the providers that implement it.

### Filter by Provider

Provider filters answer a practical question: “Which EODAG product types can this particular backend serve?” First inspect Copernicus Data Space:

```
eodag list --provider cop_dataspace --no-fetch |
  grep '^\* '
```{{exec}}

Now inspect Earth Search, the public STAC provider used explicitly in the Python and STAC API examples:

```
eodag list --provider earth_search --no-fetch |
  grep '^\* '
```{{exec}}

The compact output contains only the product-type IDs. Remove the `grep` portion whenever you want the full descriptions.

### Filter by Platform

Filters can be combined. This query asks which Sentinel-2 product types EODAG can access through Earth Search:

```
eodag list \
  --provider earth_search \
  --platform SENTINEL2 \
  --no-fetch |
  grep '^\* '
```{{exec}}

Notice the distinction between a **platform** (`SENTINEL2`) and a **product type** (`S2_MSI_L1C` or `S2_MSI_L2A_COG`). One mission can produce several processing levels and data formats.

### Filter by Sensor Type

The same mechanism can select broad data characteristics. Ask for optical product types available from Earth Search:

```
eodag list \
  --provider earth_search \
  --sensorType OPTICAL \
  --no-fetch |
  grep '^\* '
```{{exec}}

This kind of filter is useful when an application knows the observation characteristics it needs but has not yet chosen a specific mission.

### Discover New Product Types

The built-in definitions are maintained with EODAG, while provider catalogues continue to evolve. `discover` contacts one provider and serialises product types advertised by its live API:

```
eodag discover -p earth_search --storage /tmp/earth_search_products.json
```{{exec}}

Count the provider-native collections returned and display a sample:

```
printf "Discovered Earth Search collections: "
jq '.earth_search.product_types_config | length' /tmp/earth_search_products.json
jq -r '
  .earth_search.product_types_config
  | to_entries[:8][]
  | "- \(.key): \(.value.title)"
' /tmp/earth_search_products.json
```{{exec}}

Discovery does not download EO data. It reads catalogue metadata that can be reviewed before adding or overriding provider configuration.

### Provider Behaviour to Remember

Providers are not interchangeable mirrors. They may expose different:

- missions, processing levels, and archive dates;
- search parameters and result limits;
- authentication requirements;
- metadata detail and downloadable asset layouts.

The Data Gateway provides a common interface while still allowing provider-specific capabilities where they are needed.
