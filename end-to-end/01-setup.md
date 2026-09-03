Before we can reproduce the E2E notebook's workflow, we need IAM, Workspace and Data Access
(eoAPI) running - this takes around 30-45 minutes, mostly image pulls and Postgres/eoAPI
initialisation.

```
bash setup-environment.sh
```{{exec}}

Once this finishes, a sample datacube-ready STAC collection is already loaded into eoAPI.
