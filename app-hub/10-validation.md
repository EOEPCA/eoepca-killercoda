
## Validation

Run the Deployment Guide's validation script:

```bash
bash validation.sh
```{{exec}}

It checks the Keycloak client, the Hub's deployments, services and database volume, and that `/hub/login` responds.

Check the spawned profile once more:

```bash
kubectl get pods -n ws-eric
```{{exec}}

The JupyterLab pod should show `1/1` containers ready and `Running` status.
