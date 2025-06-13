Before proceeding with the Data Acces Building Block deployment, we need first to configure it. We can do it with the configuration script `configure-data-access.sh` provided in the EOEPCA dployment guide.
```
bash configure-data-access.sh
```{{exec}}

The script will start with the general EOEPCA configuration and move on sto the now the Resource Discovery building block specific configuration. We do not need to update domain and storage class, we will use what's already set, so we answer `no` to both questions:
```
no
no
```{{exec}}

S3 Host URL
```
minio.eoepca.local
```{{exec}}

S3_ACCESS_KEY is already set to 'eoepca'. Do you want to update it
```
no
```{{exec}}

S3_SECRET_KEY is already set to 'eoepcatest'. Do you want to update it
```
no
```{{exec}}

Finally, we create secrets in Kubernetes 
```
bash apply-secrets.sh
kubectl -n data-access get secrets
```{{exec}}