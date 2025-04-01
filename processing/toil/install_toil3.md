the Toil WES service requires first the execution of a [RabbitMQ](https://www.rabbitmq.com/) server for queuing jobs, which we can run in a docker container for simplicity via

```
docker run -d --restart=always --name toil-wes-rabbitmq -p 127.0.0.1:5672:5672 rabbitmq:3.9.5
```{{exec}}

then we need a celery broker to manage the queue, which we can start with

```
celery --broker=amqp://guest:guest@127.0.0.1:5672// -A toil.server.celery_app multi start w1 \
   --loglevel=INFO --pidfile=$HOME/celery.pid --logfile=$HOME/celery.log
```{{exec}}

at last we can start the Toil WES service via

```
TOIL_WES_BROKER_URL=amqp://guest:guest@127.0.0.1:5672// nohup toil server --host 0.0.0.0 \ 
  --opt=--batchSystem=htcondor \
  --logFile $HOME/toil.log --logLevel INFO -w 1 \
  &>$HOME/toil_run.log </dev/null &
echo "$!" > $HOME/toil.pid
```{{exec}}

If all went fine, we should have now our Toil WES interface available. We can check by running

```
curl -s -S http://toil-wes.hpc.local:8080
```{{exec}}

We can now go back to our `controlplane` tab, to install and configure the EOEPCA Processing Building Block
