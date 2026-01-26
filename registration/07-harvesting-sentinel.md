To use the Sentinel harvester worker deployed earlier, a workflow consisting of two BPMN processes must be added to Flowable. The main process (Sentinel Registration) searches for new data at CDSE. For each new scene found, the workflow executes another process (Sentinel Scene Ingestion) which performs the individual steps for harvesting and registering the data.

To add the main workflow, `sentinel.bpmn` use

```
source ~/.eoepca/state
curl -s https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/workflows/sentinel.bpmn | \
curl -s -X POST "http://registration-harvester-api.eoepca.local/flowable-rest/service/repository/deployments" \
  -u ${FLOWABLE_ADMIN_USER}:${FLOWABLE_ADMIN_PASSWORD} \
  -F "sentinel.bpmn=@-;filename=sentinel.bpmn;type=text/xml" | jq
```{{exec}}

and to add the sub-workflow `sentinel-scene-ingestion.bpmn` for individual scene ingestion

```
curl -s https://raw.githubusercontent.com/EOEPCA/registration-harvester/refs/heads/main/workflows/sentinel-scene-ingestion.bpmn | \
curl -s -X POST "http://registration-harvester-api.eoepca.local/flowable-rest/service/repository/deployments" \
  -u ${FLOWABLE_ADMIN_USER}:${FLOWABLE_ADMIN_PASSWORD} \
  -F "sentinel-scene-ingestion.bpmn=@-;filename=sentinel-scene-ingestion.bpmn;type=text/xml" | jq
```{{exec}}

A harvesting job targetting a small time range can now be started in Flowable using its API

```
source ~/.eoepca/state
# Get process ID
processes="$( \
  curl -s "http://registration-harvester-api.eoepca.local/flowable-rest/service/repository/process-definitions" \
    -u "${FLOWABLE_ADMIN_USER}:${FLOWABLE_ADMIN_PASSWORD}" \
  )"
sentinel_process_id="$(echo "$processes" | jq -r '[.data[] | select(.name == "Sentinel Registration")][0].id')"

# Start harvesting
curl -s -X POST "http://registration-harvester-api.eoepca.local/flowable-rest/service/runtime/process-instances" \
  -u "${FLOWABLE_ADMIN_USER}:${FLOWABLE_ADMIN_PASSWORD}" \
  -H "Content-Type: application/json" \
  -d @- <<EOF | jq
{
  "processDefinitionId": "$sentinel_process_id",
  "variables": [
    {
      "name": "filter",
      "type": "string",
      "value": "startswith(Name,'S2') and contains(Name,'L2A') and contains(Name,'_N05') and PublicationDate ge 2025-11-13T10:00:00Z and PublicationDate lt 2025-11-13T10:00:30Z and Online eq true"
    }
  ]
}
EOF
```{{exec}}

The `_N05` indicates processing baseline 5.xx - Sentinel 2 Collection 1 data is all data from this baseline onwards. The harvester is written to harvest all MSIL2A products into the sentinel-2-c1-l2a Collection created earlier.

It may take some time to harvest. The harvester worker's log output can be viewed with (use ctrl-C to exit)

```
kubectl -n resource-registration logs -f deploy/registration-harvester-worker-sentinel
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
curl "http://resource-catalogue.eoepca.local/collections/sentinel-2-c1-l2a/items" | jq
```{{exec}}

The harvested items are best visualised via the [web UI of the Resource Discovery]({{TRAFFIC_HOST1_81}}/collections/sentinel-2-c1-l2a/items).

We start a simple nginx server to offer the harvetsed data for retrieval via the asset URLs configured in the registered STAC items.

```
kubectl apply -f registration-harvester/generated-eodata-server.yaml
```{{exec}}

Once harvested, you should be able to see the data files listed in the STAC items, for example

```
curl http://eodata.eoepca.local/sentinel/eodata/Sentinel-2/MSI/L2A/2025/11/13/S2B_MSIL2A_20251113T083119_N0511_R021_T37TBF_20251113T091555.SAFE/manifest.safe
```{{exec}}
