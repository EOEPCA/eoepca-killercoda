The Toil WES service first requires a [RabbitMQ](https://www.rabbitmq.com/) server for queuing jobs, which we can run in a Docker container for simplicity:

```
docker run -d \
  --restart=always \
  --name toil-wes-rabbitmq \
  -p 127.0.0.1:5672:5672 \
  rabbitmq:3.13-alpine
```{{exec}}

RabbitMQ is pinned to the validated 3.13 release so that its queue behavior remains compatible with Celery.

Then we need a Celery worker to manage the queue, which we can start with:

```
celery \
  --broker=amqp://guest:guest@127.0.0.1:5672// \
  -A toil.server.celery_app multi start w1 \
  --loglevel=INFO \
  --pidfile=$HOME/celery.pid \
  --logfile=$HOME/celery.log
```{{exec}}

At last, start the Toil WES service. The two `--opt` values configure every workflow to use HTCondor and the shared work directory:

```
mkdir -p $HOME/toil/storage/workdir $HOME/toil/storage/workflows
TOIL_WES_BROKER_URL=amqp://guest:guest@127.0.0.1:5672// \
  nohup toil server \
    --host 0.0.0.0 \
    --work_dir $HOME/toil/storage/workflows \
    --opt=--batchSystem=htcondor \
    --opt=--workDir=$HOME/toil/storage/workdir \
    --logFile $HOME/toil.log \
    --logLevel INFO \
    -w 1 \
    >$HOME/toil_run.log 2>&1 </dev/null &
echo "$!" > $HOME/toil.pid
```{{exec}}

If everything went well, the Toil WES interface is now available. Poll it for up to one minute:

```
for attempt in {1..12}; do
  if curl --fail --silent \
    http://toil-wes.hpc.local:8080/ga4gh/wes/v1/service-info \
    > /tmp/toil-service-info.json; then
    break
  fi
  sleep 5
done
jq '{version, workflow_engine_versions, default_workflow_engine_parameters}' \
  /tmp/toil-service-info.json
```{{exec}}

The response should report Toil 9.3.0 and show HTCondor as a default workflow engine parameter.

We can now go back to our `controlplane` user to install and configure the EOEPCA Processing Building Block:

```
[[ "$(id -nu)" == "ubuntu" ]] && exit
```{{exec}}

and navigate to the Deployment Guide repository scripts for the OGC API Process interface:

```
cd ~/deployment-guide/scripts/processing/oapip
```{{exec}}
