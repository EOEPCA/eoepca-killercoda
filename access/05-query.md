In the previous step we registered a sample record using `pycsw-admin.py`, then we created a sample STAC collection using the same tool and inserted an item to the collection using the STAC API. Let's verify if our records are present in the catalogue.

First, let's check the OGC API endpoint `/collections`. It should return all the records present in the catalogue:
- sample record
- our STAC collection
- the item belonging to the STAC collection
```
curl -s http://resource-catalogue.eoepca.local/collections/metadata:main/items | jq
```{{exec}}

As you can see, the number of returned records is indeed 3 and if we analyze the JSON output, indeed all the abovementioned records can be seen.

Now, let's check the STAC endpoint. First, STAC collection:
```
curl -s http://resource-catalogue.eoepca.local/stac/collections | jq
```{{exec}}

Our STAC collection `demo-collection` is the only collection present. Let's retrieve it directly by its identifier:
```
curl -s http://resource-catalogue.eoepca.local/stac/collections/demo-collection | jq
```{{exec}}

Now let's get all items belonging to our STAC collection:
```
curl -s http://resource-catalogue.eoepca.local/stac/collections/demo-collection/items | jq
```{{exec}}

There is just one item and it is the `sample-dataset` inserted with the STAC API endpoint.

Let's take a different approach and search for the item using STAC query:
```
curl -X POST http://resource-catalogue.eoepca.local/stac/search \
  -H "Content-Type: application/json" \
  -d '{
    "bbox": [9.0, 44.0, 11.0, 46.0],
    "datetime": "2023-01-01T00:00:00Z/2023-12-31T23:59:59Z",
    "collections": ["demo-collection"]
  }' | jq
```{{exec}}

Again, we have our item from the `demo-collection` returned.

Finally, let's perform a full-text search using query parameter `q`. We will search for the sample record that was inserted from XML using `pycsw-admin.py` and has the title "EOEPCA Sample Record". We will use the HTTP GET method, therefore the spaces in the query must by URLencoded.
```
curl -s http://resource-catalogue.eoepca.local/stac/search?q=EOEPCA%20Sample%20Record | jq
```{{exec}}
