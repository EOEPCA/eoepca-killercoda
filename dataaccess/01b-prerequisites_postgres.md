The Data Access Building Block, as other EOEPCA building blocks, can be deployed with an internal dedicated PostgreSQL+PostGIS database, or an external one shared across the Kubernetes cluster. In this tutorial we have already installed and configured an external PostgreSQL database, with PostGIS enabled. We can test access to it via:

```
PGPASSWORD=eoapi psql -h eoapi-db.eoepca.local -U eoapi eoapi -c 'SELECT PostGIS_Version();'
```{{exec}}

Now we need to install [PgSTAC](https://stac-utils.github.io/pgstac/) into our database, as this is a pre-requisite for the building block. To do so, we just load the latest PgSTAC distribution (as PostgreSQL admin user)

```
curl -L https://github.com/stac-utils/pgstac/raw/refs/tags/v0.9.6/src/pgstac/pgstac.sql | su - postgres -c 'psql eoapi'
```{{exec}}

We then enable and give rights to the `eoapi`{{}} user, the user that eoapi will use to access the database, full read/write rights to the STAC items managed by PgSTAC via

```
echo 'ALTER ROLE eoapi SET SEARCH_PATH TO pgstac, public;
GRANT pgstac_ingest TO eoapi;' | su - postgres -c 'psql eoapi'
```{{exec}}

At this point we should check that PgSTAC is correctly installed via

```
PGPASSWORD=eoapi psql -h eoapi-db.eoepca.local -U eoapi eoapi -c "SELECT check_pgstac_settings('8GB');"
```{{exec}}

We can now start deploying our data access component.

