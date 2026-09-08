
## Inspect the User Workspace

The Hub runs each user's server in a namespace of its own, named after the `RESOURCE_MANAGER_WORKSPACE_PREFIX` value and the username:

```bash
kubectl get pods -n ws-eric
```{{exec}}

The pod should be `Running`. Now look at the settings the Hub took from the profile:

```bash
kubectl describe pod jupyter-eric-dev -n ws-eric
```{{exec}}

Read the container's `Image` and `Limits`: both come from the profile definition. `Node-Selectors` holds the `NODE_SELECTOR_KEY`/`NODE_SELECTOR_VALUE` pair you gave to `configure-app-hub.sh`, which is how a Platform Operator keeps user sessions on a chosen node pool.

The Hub logs the decisions it made for this spawn:

```bash
kubectl logs -n app-hub deploy/application-hub-hub | grep Initialising
```{{exec}}
