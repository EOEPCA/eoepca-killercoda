For this tutorial, we'll use the pre-deployed "echo" process to demonstrate job execution with Argo Workflows.

First, let's verify the echo process is available:

```bash
# List available processes
curl -s http://localhost:8080/ogc-api/processes | jq '.processes[].id'
```{{exec}}

Get the process description:

```bash
curl -s http://localhost:8080/ogc-api/processes/echo | jq .
```{{exec}}

Execute the echo process with a simple input:

```bash
cat <<'EOF' > execute-echo-correct.json
{
  "inputs": {
    "a": "Hello from Argo Workflows!"
  },
  "outputs": {
    "a": {
      "transmissionMode": "value"
    }
  }
}
EOF

JOB_LOCATION=$(curl -X POST http://localhost:8080/ogc-api/processes/echo/execution \
  -H "Content-Type: application/json" \
  -H "Prefer: respond-async" \
  -d @execute-echo-correct.json \
  -i | grep -i "location:" | cut -d' ' -f2 | tr -d '\r')

echo "Job created at: $JOB_LOCATION"

# Check status
sleep 2
curl -s $JOB_LOCATION | jq .
```{{exec}}