We are configuring the Toil WES processing engine, so select it now:

```
toil
```{{exec}}

The script asks for the Toil WES endpoint. Use the service started in the previous step:

```
http://toil-wes.hpc.local:8080/ga4gh/wes/v1/
```{{exec}}

We did not implement authentication on our Toil WES endpoint because this is a test system. Provide the following placeholder credentials; the WES service will ignore them:

```
test
$2y$12$ci.4U63YX83CwkyUrjqxAucnmi2xXOIlEF6T/KdP9824f1Rf1iyNG
```{{exec}}

The script has now generated the Helm values for our building-block deployment. Check the main integration settings without displaying the stored credentials:

```
grep -n -E 'templateUrl|WES_URL|STAGE(IN|OUT)_AWS_SERVICEURL|storageClass|hosturl' \
  generated-values.yaml
```{{exec}}

The values should reference the Toil WES endpoint, the MinIO stage-in and stage-out service, and the configured storage classes.
