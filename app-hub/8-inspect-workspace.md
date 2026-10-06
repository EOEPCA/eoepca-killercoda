
## Inspect the User Workspace

The Hub runs each user's server in a namespace of its own, named after the `RESOURCE_MANAGER_WORKSPACE_PREFIX` value and the username:

```bash
kubectl get pods -n ws-eric
```{{exec}}

The pod should be `Running`. The profiles are defined in the Hub's configuration file. Look at the Streamlit profile:

```bash
kubectl exec -n app-hub deploy/application-hub-hub -- grep -A12 'id: profile_studio_dashboard' /usr/local/etc/applicationhub/config.yml
```{{exec}}

`groups` decides who is offered the profile, `kubespawner_override` sets the image and limits, and `node_selector` comes from the values you gave to `configure-app-hub.sh`.

Now compare it with the pod the Hub created:

```bash
kubectl describe pod jupyter-eric-dev -n ws-eric
```{{exec}}

The container's `Image` and `Limits` match the profile, and `Node-Selectors` holds the same `NODE_SELECTOR_KEY`/`NODE_SELECTOR_VALUE` pair. This is how a Platform Operator keeps user sessions on a chosen node pool.

The Hub logs the decisions it made for this spawn:

```bash
kubectl logs -n app-hub deploy/application-hub-hub | grep Initialising
```{{exec}}
