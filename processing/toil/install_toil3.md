The Toil WES service first requires a [RabbitMQ](https://www.rabbitmq.com/) server for queuing jobs, which we can run in a Docker container for simplicity:

```
docker run -d \
  --restart=always \
  --name toil-wes-rabbitmq \
  -p 127.0.0.1:5672:5672 \
  rabbitmq:4.1-alpine
```{{exec}}

Then we need a Celery worker to manage the queue, which we can start with:

```
source ~/toil/venv/bin/activate

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

The WES interface takes a few seconds to accept requests, so let curl retry until it answers:

```
curl --fail --silent --show-error --retry 12 --retry-delay 5 --retry-connrefused \
  http://toil-wes.hpc.local:8080/ga4gh/wes/v1/service-info | jq
```{{exec}}

The response reports Toil 9.3.0 and lists `--batchSystem=htcondor` under `default_workflow_engine_parameters`.

We can now go back to our `controlplane` user to install and configure the EOEPCA Processing Building Block:

```
[[ "$(id -nu)" == "ubuntu" ]] && exit
```{{exec}}

and navigate to the Deployment Guide repository scripts for the OGC API Process interface:

```
cd ~/deployment-guide/scripts/processing/oapip
```{{exec}}
