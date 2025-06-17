Let’s register some sample items in the Resource Catalogue. We will use two methods of doing that:
- PyCSW admin script
- STAC API

### Add metadata with PyCSW admin script

We will inject a sample record with the PyCSW admin script, as described in the EOEPCA Deployment Guide.

The sample file is `sample_record.xml` and is provided with the Deployment Guide scripts. Here's its content:
```
cat sample_record.xml
```{{exec}}

We need to identify the Resource Discovery service pod and copy the sample file into the pod:
```
RESOURCE_CATALOGUE_POD=`kubectl -n resource-discovery get pods --no-headers -o custom-columns=NAME:.metadata.name | grep resource-catalogue-service`
kubectl -n resource-discovery cp sample_record.xml ${RESOURCE_CATALOGUE_POD}:/tmp/
```{{exec}}

Then, we run the `pycsw-admin.py` script inside the pod, pointing it to the copied file as the source:
```
kubectl -n resource-discovery exec -it ${RESOURCE_CATALOGUE_POD} -- /usr/local/bin/pycsw-admin.py load-records --config /etc/pycsw/pycsw.yml --path /tmp/sample_record.xml
```{{exec}}

### Add metadata via STAC API

We will inject a sample dataset to a STAC collection, using the STAC API endpoint `/stac/collections/[collection]/items` exposed by the Resource Discovery service.

Since we have no STAC collections initially, we must create one first. This is impossible to be done with the STAC API endpoint `/stac/collections` so we will use again `pycsw-admin.py` for that, and a STAC collection definition in XML:
```
cat <<EOF > collection.xml
<?xml version="1.0" encoding="UTF-8"?>
<gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd"
                 xmlns:gco="http://www.isotc211.org/2005/gco"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:schemaLocation="http://www.isotc211.org/2005/gmd
                                     http://schemas.opengis.net/iso/19139/20070417/gmd/gmd.xsd">

  <gmd:fileIdentifier>
    <gco:CharacterString>demo-collection</gco:CharacterString>
  </gmd:fileIdentifier>
  <gmd:language>
    <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/"
                      codeListValue="eng">eng</gmd:LanguageCode>
  </gmd:language>
  <gmd:characterSet>
    <gmd:MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_CharacterSetCode"
                             codeListValue="utf8"/>
  </gmd:characterSet>
  <gmd:hierarchyLevel>
    <gmd:MD_ScopeCode codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_ScopeCode"
                      codeListValue="dataset"/>
  </gmd:hierarchyLevel>
  <gmd:contact>
    <gmd:CI_ResponsibleParty>
      <gmd:organisationName>
        <gco:CharacterString>EOEPCA</gco:CharacterString>
      </gmd:organisationName>
      <gmd:role>
        <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/codeList.xml#CI_RoleCode"
                         codeListValue="pointOfContact"/>
      </gmd:role>
    </gmd:CI_ResponsibleParty>
  </gmd:contact>
  <gmd:dateStamp>
    <gco:Date>2025-06-10</gco:Date>
  </gmd:dateStamp>
  <gmd:identificationInfo>
    <gmd:MD_DataIdentification>
      <gmd:citation>
        <gmd:CI_Citation>
          <gmd:title>
            <gco:CharacterString>Demo Collection</gco:CharacterString>
          </gmd:title>
          <gmd:date>
            <gmd:CI_Date>
              <gmd:date>
                <gco:Date>2025-06-10</gco:Date>
              </gmd:date>
              <gmd:dateType>
                <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/codeList.xml#CI_DateTypeCode"
                                     codeListValue="creation"/>
              </gmd:dateType>
            </gmd:CI_Date>
          </gmd:date>
        </gmd:CI_Citation>
      </gmd:citation>
      <gmd:abstract>
        <gco:CharacterString>Test STAC Collection in ISO 19139 format for pycsw.</gco:CharacterString>
      </gmd:abstract>
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <gmd:keyword>
            <gco:CharacterString>STAC</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Collection</gco:CharacterString>
          </gmd:keyword>
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>
      <gmd:extent>
        <gmd:EX_Extent>
          <gmd:geographicElement>
            <gmd:EX_GeographicBoundingBox>
              <gmd:westBoundLongitude>
                <gco:Decimal>-180.0</gco:Decimal>
              </gmd:westBoundLongitude>
              <gmd:eastBoundLongitude>
                <gco:Decimal>180.0</gco:Decimal>
              </gmd:eastBoundLongitude>
              <gmd:southBoundLatitude>
                <gco:Decimal>-90.0</gco:Decimal>
              </gmd:southBoundLatitude>
              <gmd:northBoundLatitude>
                <gco:Decimal>90.0</gco:Decimal>
              </gmd:northBoundLatitude>
            </gmd:EX_GeographicBoundingBox>
          </gmd:geographicElement>
        </gmd:EX_Extent>
      </gmd:extent>
    </gmd:MD_DataIdentification>
  </gmd:identificationInfo>
</gmd:MD_Metadata>

EOF
```{{exec}}

And again, we copy the collection XML  file into the Resource Discovery service pod and run `pycsw-admin.py` from there:
```
kubectl -n resource-discovery cp collection.xml ${RESOURCE_CATALOGUE_POD}:/tmp/
kubectl -n resource-discovery exec -it ${RESOURCE_CATALOGUE_POD} -- /usr/local/bin/pycsw-admin.py load-records --config /etc/pycsw/pycsw.yml --path /tmp/collection.xml
```{{exec}}

Finally, we inject a sample dataset to the newly created STAC collection  using the STAC API endpoint exposed by the Resource Discovery service.

First, we will create a file with simple JSON metadata:
```
cat <<EOF > item.json
{
  "type": "Feature",
  "stac_version": "1.0.0",
  "id": "sample-dataset",
  "properties": {
    "datetime": "2023-12-01T00:00:00Z"
  },
  "geometry": {
    "type": "Point",
    "coordinates": [10.0, 45.0]
  },
  "links": [],
  "assets": {},
  "collection": "demo-collection"
}
EOF
```{{exec}}

And then we will ingest the item to the catalague using the STAC API endpoint:

```
curl -X POST http://resource-catalogue.eoepca.local/stac/collections/demo-collection/items \
  -H "Content-Type: application/json" \
  -d @item.json
```{{exec}}
