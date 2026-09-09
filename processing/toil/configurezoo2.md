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

Inspect the Helm values the script generated:

```
less generated-values.yaml
```{{exec}}

They reference the Toil WES endpoint, the MinIO stage-in and stage-out service, and the configured storage classes. Press `q`{{exec}} to exit.

Run the deployment guide prerequisite checks using the configuration you just saved:

```
bash check-prerequisites.sh
```{{exec}}
