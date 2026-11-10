Deploy Workspace and IAM-enabled Data Access using the deployment guide's configuration scripts and Helm charts. IAM and shared services are installed by the background setup.

```
bash /tmp/assets/setup-environment.sh
```{{exec}}

The script waits for readiness and installs the notebook's Python dependencies. Image pulls and database initialisation can take several minutes. 
