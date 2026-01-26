We can use the registration API to harvest a STAC Collection from an external URL. This example registers the STAC Collection landsat-ot-c2-l2  into the EOEPCA Resource Catalogue instance - representing the Landsat 8-9 OLI/TIRS Collection 2 Level-2. This collection is used in later steps as a target for harvesting the example Landsat data.

The target of this registration request is the STAC endpoint of the Resource Catalogue service deployed as part of the Resource Discovery Building Block.

Note that, as this tutorial does not deploy the IAM BB and Crossplane, no authentication is required. See the full EOEPCA Deployment Guide to see an example of Resource Registration API access with a bearer token.

```
curl -X POST "http://registration-api.eoepca.local/processes/register/execution" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
    "inputs": {
        "source": {"rel": "collection", "href": "https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/etc/collections/landsat/landsat-ot-c2-l2.json"},
        "target": {"rel": "https://api.stacspec.org/v1.0.0/core", "href": "http://resource-catalogue.eoepca.local/stac"}
    }
}
EOF
```{{exec}}

If Sentinel harvesting is enabled, we also need the Sentinel 2 L2A Collection 1 STAC collection to harvest into:

```
curl -X POST "http://registration-api.eoepca.local/processes/register/execution" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
    "inputs": {
        "source": {"rel": "collection", "href": "https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/etc/collections/sentinel/sentinel-2-c1-l2a.json"},
        "target": {"rel": "https://api.stacspec.org/v1.0.0/core", "href": "http://resource-catalogue.eoepca.local/stac"}
    }
}
EOF
```{{exec}}

A OGC Processes API Job should have run to ingest the Collection. You can see its state using the API

```
curl http://registration-api.eoepca.local/jobs | jq
```{{exec}}

You should be able to see the ingested collections in the Resource Discovery BB's OGC Records API

```
curl http://resource-catalogue.eoepca.local/collections/landsat-ot-c2-l2 | jq
```{{exec}}

and also at its STAC API

```
curl http://resource-catalogue.eoepca.local/stac/collections/landsat-ot-c2-l2 | jq
```{{exec}}

and for Sentinel 2

```
curl http://resource-catalogue.eoepca.local/stac/collections/sentinel-2-c1-l2a | jq
```{{exec}}
