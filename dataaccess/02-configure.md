Before proceeding with the Data Acces Building Block deployment, we need first to configure it. We can do it with the configuration script `configure-data-access.sh` provided in the EOEPCA deployment guide.

```
bash configure-data-access.sh
```{{exec}}

The script will start with the general EOEPCA configuration and move on sto the now the Resource Discovery building block specific configuration. We do not need to update domain and storage class, we will use what's already set, so we answer `no`{{}} to both questions:
```
no
no
```{{exec}}

We use an external database in this tutoria, thus we can answer
```
true
```{{exec}}

And we can keep all the default values for the external database

```
eoapi-db.eoepca.local
5432
eoapi
eoapi
eoapi
```{{exec}}

We will have now our `generated-values.yaml`{{}} file with the configuration of the Data Access building block.

We also need to generate some secrets in our kubernetes cluster in order for the components to run:
```
bash apply-secrets.sh
```{{exec}}

