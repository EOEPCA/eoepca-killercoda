
## Create the Keycloak Client

The Application Hub requires an OIDC client in Keycloak for authentication. We'll create this using the Crossplane Keycloak provider.

Wait for the Crossplane provider to be ready:

```bash
kubectl wait --for=condition=Healthy provider/provider-keycloak -n crossplane-system --timeout=2m 2>/dev/null || echo "Waiting for provider..."
```{{exec}}

`configure-app-hub.sh` already rendered `generated-iam.yaml` with the client's exact callback URL. Apply it:

```bash
kubectl apply -f generated-iam.yaml
```{{exec}}
