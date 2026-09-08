Register the Application Package in the `test` user context. With authentication disabled, the path identifies a context but does not restrict access to it.

List its processes:

```
curl -sS http://zoo.eoepca.local/test/ogc-api/processes/ | jq
```{{exec}}

Post the CWL file from the deployment guide examples:

```
curl -sS -X POST \
  -H "Content-Type: application/cwl+yaml" \
  -H "Accept: application/json" \
  --data-binary @examples/convert-url-app.cwl \
  http://zoo.eoepca.local/test/ogc-api/processes/ | jq
```{{exec}}

Inspect the registered process:

```
curl -sS http://zoo.eoepca.local/test/ogc-api/processes/convert-url | jq
```{{exec}}

The description includes the `fn`, `url` and `size` inputs. Registration stores the Application Package; application pods are started when you submit an execution.
