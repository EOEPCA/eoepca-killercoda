To use the Landsat harvester worker deployed earlier, a workflow consisting of two BPMN processes must be added to Operaton. The main process (Landsat Registration) searches for new data at USGS. For each new scene found, the workflow executes another process (Landsat Scene Ingestion) which performs the individual steps for harvesting and registering the data.

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
curl "http://resource-catalogue.eoepca.local/collections/landsat-ot-c2-l2/items" | jq
```{{exec}}

The harvested items are best visualised via the [web UI of the Resource Discovery]({{TRAFFIC_HOST1_81}}/collections/landsat-ot-c2-l2/items).
