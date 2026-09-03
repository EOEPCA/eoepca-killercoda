The Resource Registration BB includes a generic STAC harvester, which harvests a collection directly from any publicly-accessible STAC API - requiring no provider credentials. This is the primary way to harvest data in this tutorial. This example harvests two Sentinel-2 scenes from a real STAC catalogue, [Microsoft's Planetary Computer](https://planetarycomputer.microsoft.com/), registering them into the Data Access BB's STAC API deployed earlier in this tutorial.

Deploy its workflow to Operaton:

```
source ~/.eoepca/state
curl -s https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/workflows/stac.bpmn | \
curl -s -X POST "${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/deployment/create" \
      -u "${OPERATON_ADMIN_USER}:${OPERATON_ADMIN_PASSWORD}" \
      -F "deployment-name=stac" \
      -F "stac.bpmn=@-;filename=stac.bpmn;type=text/xml" | jq
```{{exec}}

Start a harvest limited to a small area and time window, matching two scenes:

```
source ~/.eoepca/state
curl -s -X POST "${HTTP_SCHEME}://registration-harvester-bpm-engine.${INGRESS_HOST}/engine-rest/process-definition/key/stac-harvest-catalog/start" \
  -H "Content-Type: application/json" \
  -d @- <<EOF | jq
{
  "variables": {
    "stac_catalog_source": {"value": "https://planetarycomputer.microsoft.com/api/stac/v1", "type": "String"},
    "stac_catalog_collections": {"value": "sentinel-2-l2a", "type": "String"},
    "stac_api_destination_url": {"value": "${HTTP_SCHEME}://eoapi.${INGRESS_HOST}/stac", "type": "String"},
    "datetime": {"value": "2026-09-02T00:00:00Z/2026-09-02T23:59:59Z", "type": "String"},
    "bbox": {"value": "-1.3,51.4,-1.1,51.5", "type": "String"}
  }
}
EOF
```{{exec}}

It may take a few seconds to harvest. The harvester worker's log output can be viewed with (use ctrl-C to exit)

```
kubectl -n resource-registration logs -f deploy/registration-harvester-worker-stac
```{{exec}}

Once complete, the two harvested scenes are visible directly via the STAC API:

```
curl -s "http://eoapi.eoepca.local/stac/collections/sentinel-2-l2a/items" | jq '[.features[] | {id, datetime: .properties.datetime}]'
```{{exec}}

and via the STAC Browser bundled with the Data Access BB, at [this link]({{TRAFFIC_HOST1_89}}/browser/#/external/eoapi.eoepca.local/stac/collections/sentinel-2-l2a) or within the cluster at `http://eoapi.eoepca.local/browser/#/external/eoapi.eoepca.local/stac/collections/sentinel-2-l2a`.
