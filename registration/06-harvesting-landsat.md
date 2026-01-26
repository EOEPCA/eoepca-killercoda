To use the Landsat harvester worker deployed earlier, a workflow consisting of two BPMN processes must be added to Flowable. The main process (Landsat Registration) searches for new data at USGS. For each new scene found, the workflow executes another process (Landsat Scene Ingestion) which performs the individual steps for harvesting and registering the data.

To add the main workflow, `landsat.bpmn` use

```
source ~/.eoepca/state
curl -s https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/workflows/landsat.bpmn | \
curl -s -X POST "http://registration-harvester-api.eoepca.local/flowable-rest/service/repository/deployments" \
  -u ${FLOWABLE_ADMIN_USER}:${FLOWABLE_ADMIN_PASSWORD} \
  -F "landsat.bpmn=@-;filename=landsat.bpmn;type=text/xml" | jq
```{{exec}}

and to add the sub-workflow `landsat-scene-ingestion.bpmn` for individual scene ingestion

```
curl -s https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/workflows/landsat-scene-ingestion.bpmn | \
curl -s -X POST "http://registration-harvester-api.eoepca.local/flowable-rest/service/repository/deployments" \
  -u ${FLOWABLE_ADMIN_USER}:${FLOWABLE_ADMIN_PASSWORD} \
  -F "landsat-scene-ingestion.bpmn=@-;filename=landsat-scene-ingestion.bpmn;type=text/xml" | jq
```{{exec}}

A harvesting job targetting a small AoI and time range can now be started in Flowable using its API

```
source ~/.eoepca/state
# Get process ID
processes="$( \
  curl -s "http://registration-harvester-api.eoepca.local/flowable-rest/service/repository/process-definitions" \
    -u "${FLOWABLE_ADMIN_USER}:${FLOWABLE_ADMIN_PASSWORD}" \
  )"
landsat_process_id="$(echo "$processes" | jq -r '[.data[] | select(.name == "Landsat Workflow")][0].id')"

# Start harvesting
curl -s -X POST "http://registration-harvester-api.eoepca.local/flowable-rest/service/runtime/process-instances" \
  -u "${FLOWABLE_ADMIN_USER}:${FLOWABLE_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d @- <<EOF | jq
{
  "processDefinitionId": "$landsat_process_id",
  "variables": [
    {
      "name": "datetime_interval",
      "type": "string",
      "value": "2024-11-13T10:00:00Z/2024-11-13T11:00:00Z"
    },
    {
      "name": "collections",
      "type": "string",
      "value": "landsat-c2l2-sr"
    },
    {
      "name": "bbox",
      "type": "string",
      "value": "-7,46,3,52"
    }
  ]
}
EOF
```{{exec}}

It may take some time to harvest. The harvester worker's log output can be viewed with (use ctrl-C to exit)

```
kubectl -n resource-registration logs -f deploy/registration-harvester-worker-landsat
```{{exec}}

and the Flowable job's status can be seen with

```
source ~/.eoepca/state
curl -s "http://registration-harvester-api.eoepca.local/flowable-rest/service/runtime/process-instances" \
  -u ${FLOWABLE_ADMIN_USER}:${FLOWABLE_ADMIN_PASSWORD} \
  | jq
```{{exec}}

Once complete, the catalogue will contain the harvested items which you can see with

```
curl "http://resource-catalogue.eoepca.local/collections/landsat-ot-c2-l2/items" | jq
```{{exec}}

The harvested items are best visualised via the [web UI of the Resource Discovery]({{TRAFFIC_HOST1_81}}/collections/landsat-ot-c2-l2/items).

We start a simple nginx server to offer the harvetsed data for retrieval via the asset URLs configured in the registered STAC items.

```
kubectl apply -f registration-harvester/generated-eodata-server.yaml
```{{exec}}
