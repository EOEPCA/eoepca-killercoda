> **Optional.** This step needs a USGS Machine-to-Machine (M2M) account with an *approved* Data Access Request - not just an account. Registering for M2M access alone lets you search Landsat metadata, but not download scenes; the separate access request can take several days to be approved. If you don't already have this, skip this step - the STAC Catalog harvesting step above already demonstrated real harvesting without any of this friction. You can always come back to this step later.
>
> To request access:
>
> * Register for a free account at the [USGS M2M site](https://m2m.cr.usgs.gov/)
> * Submit a Data Access Request from your profile at <https://ers.cr.usgs.gov/profile/access>
> * Once approved, create an application token from the same profile page, specifying the M2M API scope
> * Rerun `bash configure-resource-registration.sh` from the Configure step, answering `yes` to Landsat harvesting and providing these credentials, then rerun `bash apply-secrets.sh`

## Deploy the Landsat Worker

By default this worker registers harvested metadata into the Resource Discovery BB, which this tutorial does not deploy - so we override its target to register into the Data Access BB's STAC API instead, consistent with the rest of this tutorial:

```
source ~/.eoepca/state
helm upgrade -i registration-harvester-worker-landsat eoepca-dev/registration-harvester \
  --version 2.0.0 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/harvester-values/values-landsat.yaml \
  --set-string harvester.config.handlers.LandsatRegisterMetadataHandler.stac_api_url="${HTTP_SCHEME}://eoapi.${INGRESS_HOST}/stac"
```{{exec}}

We also need the Landsat 8-9 OLI/TIRS Collection 2 Level-2 STAC collection to harvest into:

```
curl -X POST "http://registration-api.eoepca.local/processes/register/execution" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
    "inputs": {
        "source": {"rel": "collection", "href": "https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/etc/collections/landsat/landsat-ot-c2-l2.json"},
        "target": {"rel": "https://api.stacspec.org/v1.0.0/core", "href": "http://eoapi.eoepca.local/stac"}
    }
}
EOF
```{{exec}}

## Deploy the Workflow

A workflow consisting of two BPMN processes must be added to Operaton. The main process (Landsat Registration) searches for new data at USGS. For each new scene found, the workflow executes another process (Landsat Scene Ingestion) which performs the individual steps for harvesting and registering the data.

To add the main workflow, `landsat.bpmn` use

```
source ~/.eoepca/state
curl -s https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/workflows/landsat.bpmn | \
curl -s -X POST "${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/deployment/create" \
      -u "${OPERATON_ADMIN_USER}:${OPERATON_ADMIN_PASSWORD}" \
      -F "deployment-name=landsat" \
      -F "landsat.bpmn=@-;filename=landsat.bpmn;type=text/xml" | jq
```{{exec}}

and to add the sub-workflow `landsat-scene-ingestion.bpmn` for individual scene ingestion

```
curl -s https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/workflows/landsat-scene-ingestion.bpmn | \
curl -s -X POST "${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/deployment/create" \
  -u "${OPERATON_ADMIN_USER}:${OPERATON_ADMIN_PASSWORD}" \
  -F "deployment-name=landsat-scene-ingestion" \
  -F "landsat-scene-ingestion.bpmn=@-;filename=landsat-scene-ingestion.bpmn;type=text/xml" | jq
```{{exec}}

## Harvest

A harvesting job targetting a small AoI and time range can now be started in Operaton using its API

```
source ~/.eoepca/state
curl -s -X POST "${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/message" \
  -H "Content-Type: application/json" \
  -d @- <<EOF | jq
{
  "messageName": "landsat-start-order",
  "processVariables": {
    "datetime_interval": {"value": "2024-11-13T10:00:00Z/2024-11-13T11:00:00Z", "type": "String"},
    "collections": {"value": "landsat_ot_c2_l2", "type": "String"},
    "bbox": {"value": "-7,46,3,52", "type": "String"}
  }
}
EOF
```{{exec}}

It may take some time to harvest. The harvester worker's log output can be viewed with (use ctrl-C to exit)

```
kubectl -n resource-registration logs -f deploy/registration-harvester-worker-landsat
```{{exec}}

and Operaton's job statuses can be seen with

```
source ~/.eoepca/state
curl ${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/job | jq .
```{{exec}}

You can also use the Operaton UIs, the [task list]({{TRAFFIC_HOST1_88}}/operaton/app/tasklist/), [cockpit]({{TRAFFIC_HOST1_88}}/operaton/app/cockpit/) and [admin]({{TRAFFIC_HOST1_88}}/operaton/app/admin/) apps. Use `grep OPERATON_ADMIN ~/.eoepca/state`{{exec}} to see the login details.


Once complete, the catalogue will contain the harvested items which you can see with

```
curl "http://eoapi.eoepca.local/stac/collections/landsat-ot-c2-l2/items" | jq
```{{exec}}

The harvested items are best visualised via the [Data Access BB's STAC Browser]({{TRAFFIC_HOST1_89}}/browser/#/external/eoapi.eoepca.local/stac/collections/landsat-ot-c2-l2/items).
