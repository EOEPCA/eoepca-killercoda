
## The Persistent Workspace

A profile can also declare a persistent volume for the user's workspace. Switch to a profile that gives you a shell, so you can write to it.

Open the [Hub control panel]({{TRAFFIC_HOST1_83}}/hub/home) and click **Stop My Server**. Then click **Start My Server** and select **IAT - Interactive Analysis Tool (JupyterLab)**.

Once JupyterLab has opened, look at what the Hub created in the workspace namespace:

```bash
kubectl get pvc,configmap -n ws-eric
```{{exec}}

`claim-workspace` is the 10Gi volume the profile mounts at `/workspace`, provisioned from the storage class you chose while checking prerequisites. The config maps hold the credentials files the profile mounts into the home directory.

> The Hub creates the user namespace as part of the first server start, so a profile's claim and config maps are only created from the second start onwards.

In JupyterLab, open **File > New > Terminal** and write a file to the workspace:

```
echo "hello from the Application Hub" > /workspace/notes.txt
```

Return to the [control panel]({{TRAFFIC_HOST1_83}}/hub/home) and click **Stop My Server**. The pod is deleted, but the claim stays:

```bash
kubectl get pods,pvc -n ws-eric
```{{exec}}

Start the server again with the same profile, open a terminal and read the file back:

```
cat /workspace/notes.txt
```

The workspace outlives the session, so a user keeps their data between servers and across the profiles that mount the same claim.
