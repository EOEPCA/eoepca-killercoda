> **Optional.** This step needs a free account with the [Copernicus Data Space Ecosystem (CDSE)](https://dataspace.copernicus.eu/). Registration is normally open to anyone, but this hasn't been extensively verified as part of this tutorial. If you don't already have an account, skip this step - the STAC Catalog harvesting step above already demonstrated real harvesting without any of this friction. You can always come back to this step later.
>
> To set this up:
>
> * Register for a free account at [CDSE](https://dataspace.copernicus.eu/)
> * Rerun `bash configure-resource-registration.sh` from the Configure step, answering `yes` to Sentinel harvesting and entering your CDSE username (email) and password, then rerun `bash apply-secrets.sh`

## Deploy the Sentinel Worker

By default this worker registers harvested metadata into the Resource Discovery BB, which this tutorial does not deploy - so we override its target to register into the Data Access BB's STAC API instead, consistent with the rest of this tutorial:

```
source ~/.eoepca/state
helm upgrade -i registration-harvester-worker-sentinel eoepca-dev/registration-harvester \
  --version 2.0.0 \
  --namespace resource-registration \
  --create-namespace \
  --values registration-harvester/harvester-values/values-sentinel.yaml \
  --set-string harvester.config.handlers.SentinelRegisterMetadataHandler.stac_api_url="${HTTP_SCHEME}://eoapi.${INGRESS_HOST}/stac"
```{{exec}}

We also need the Sentinel 2 L2A Collection 1 STAC collection to harvest into:

```
curl -X POST "http://registration-api.eoepca.local/processes/register/execution" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
    "inputs": {
        "source": {"rel": "collection", "href": "https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/etc/collections/sentinel/sentinel-2-c1-l2a.json"},
        "target": {"rel": "https://api.stacspec.org/v1.0.0/core", "href": "http://eoapi.eoepca.local/stac"}
    }
}
EOF
```{{exec}}

## Deploy the Workflow

A workflow consisting of two BPMN processes must be added to Operaton. The main process (Sentinel Registration) searches for new data at CDSE. For each new scene found, the workflow executes another process (Sentinel Scene Ingestion) which performs the individual steps for harvesting and registering the data.

To add the main workflow, `sentinel.bpmn` use

```
source ~/.eoepca/state
curl -s https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/workflows/sentinel.bpmn | \
curl -s -X POST "${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/deployment/create" \
  -u "${OPERATON_ADMIN_USER}:${OPERATON_ADMIN_PASSWORD}" \
  -F "deployment-name=sentinel" \
  -F "sentinel.bpmn=@-;filename=sentinel.bpmn;type=text/xml" | jq
```{{exec}}

and to add the sub-workflow `sentinel-scene-ingestion.bpmn` for individual scene ingestion

```
curl -s https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/workflows/sentinel-scene-ingestion.bpmn | \
curl -s -X POST "${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/deployment/create" \
  -u "${OPERATON_ADMIN_USER}:${OPERATON_ADMIN_PASSWORD}" \
  -F "deployment-name=sentinel-scene-ingestion" \
  -F "sentinel-scene-ingestion.bpmn=@-;filename=sentinel-scene-ingestion.bpmn;type=text/xml" | jq
```{{exec}}

## Harvest

A harvesting job targetting a small time range (containing three records) can now be started in Operaton using its API

```
source ~/.eoepca/state
curl -s -X POST "${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/message" \
  -H "Content-Type: application/json" \
  -d @- <<EOF | jq
{
  "messageName": "sentinel-start-order",
  "processVariables": {
    "datetime_interval": {"value": "2025-11-13T10:00:00Z/2025-11-13T10:00:30Z", "type": "String"},
    "collections": {"value": "SENTINEL-2", "type": "String"}
  }
}
EOF
```{{exec}}

This should match two images.

It may take some time to harvest. The harvester worker's log output can be viewed with (use ctrl-C to exit)

```
kubectl -n resource-registration logs -f deploy/registration-harvester-worker-sentinel
```{{exec}}


Operaton's process instances can be seen in

```bash
source ~/.eoepca/state
curl -s "${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/process-instance" \
  | jq -r '.[] | "\(.id) | \(.definitionId)"'
```{{exec}}

and the jobs it spawned with

```
source ~/.eoepca/state
curl ${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/job | jq .
```{{exec}}

Once complete, the catalogue will contain the harvested items which you can see with

```
curl "http://eoapi.eoepca.local/stac/collections/sentinel-2-c1-l2a/items" | jq
```{{exec}}

The harvested items are best visualised via the [Data Access BB's STAC Browser]({{TRAFFIC_HOST1_89}}/browser/#/external/eoapi.eoepca.local/stac/collections/sentinel-2-c1-l2a/items).

Once harvested, you should be able to see the data files listed in the STAC items, for example

```
curl http://eodata.eoepca.local/sentinel/S2B_MSIL2A_20251113T083119_N0511_R021_T37TBF_20251113T091555.SAFE/manifest.safe
```{{exec}}
