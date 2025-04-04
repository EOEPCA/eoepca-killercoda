we are configuration the Toil WES processing engine, so we need to select it

```
toil
```{{exec}}

the script is asking our Toil WES interface endpoint. From the previous Toil installation step, this is

```
http://toil-wes.hpc.local:8080/ga4gh/wes/v1/
```{{exec}}

we did not implement any authentication in our Toil WES interface endopoint, as this is a test system, so we can provide standard credentials now (they will be ignore anyway)

```
test
$2y$12$ci.4U63YX83CwkyUrjqxAucnmi2xXOIlEF6T/KdP9824f1Rf1iyNG
```{{exec}}

we now have a set of configuration values for our building block deployment available, you can check them with

```
less generated-values.yaml
```{{exec}}

NOTE: Press `q`{{exec}} to exit when you are done inspecting the file, and we can move to the next step
