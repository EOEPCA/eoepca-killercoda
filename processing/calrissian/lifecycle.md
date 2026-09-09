The building block keeps a record of every execution. List the jobs in the `test`{{}} context:

```
curl -sS http://zoo.eoepca.local/test/ogc-api/jobs | jq
```{{exec}}

Each entry keeps the process that was run, its status and the links used in the previous steps, so an earlier result can be retrieved again at any time.

Deployed applications can also be removed. Undeploy `convert-url`{{}}, printing the response status code:

```
curl -sS -o /dev/null -w "%{http_code}\n" \
  -X DELETE http://zoo.eoepca.local/test/ogc-api/processes/convert-url
```{{exec}}

The API answers `204`, and only the built-in `echo` process is left:

```
curl -sS http://zoo.eoepca.local/test/ogc-api/processes/ | jq -r '.processes[].id'
```{{exec}}

Deploy, execute and undeploy are the operations that the OGC API - Processes interface offers over an application package. Deploy the application once more, so that you can keep experimenting with it:

```
curl -sS -X POST \
  -H "Content-Type: application/cwl+yaml" \
  -H "Accept: application/json" \
  --data-binary @examples/convert-url-app.cwl \
  http://zoo.eoepca.local/test/ogc-api/processes/ | jq -r '.id'
```{{exec}}
