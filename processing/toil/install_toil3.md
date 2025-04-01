the Toil WES service requires first the execution of a [RabbitMQ](https://www.rabbitmq.com/) server for queuing jobs, which we can run in a docker container for simplicity via

```
docker run -d --restart=always --name toil-wes-rabbitmq -p 127.0.0.1:5672:5672 rabbitmq:3.9.5
```{{exec}}

then we need a celery broker to manage the queue, which we can start with

```
celery --broker=amqp://guest:guest@127.0.0.1:5672// -A toil.server.celery_app worker \
  --loglevel=INFO --pidfile="~/celery.pid" --logfile="~/celery.log"
```{{exec}}

at last we can start the Toil WES service via

```
TOIL_WES_BROKER_URL=amqp://user:bitnami@127.0.0.1:5672//  toil server --opt=--batchSystem=htcondor
```{{exec}}

