a [Toil WES interace](https://toil.readthedocs.io/en/master/running/server/wes.html) is required by EOEPCA's Processing building block to submit processing to the cluster.

As said before, an HPC cluster may already provide such interface, but, if not, like in this tutorial, it will be required to be installed in the HPC cluster submit environment. This is available from the `ubuntu` user on this tutorial.

to install toil, thus, we can run, in the `ubuntu` user tab, the following

```
#Create Toil shared storage and Toil installation directory
mkdir -p /opt/toil/toil_storage && cd /opt/toil
#Create a Python Virtual environment to install toil in
python3 -m venv venv && source venv/bin/activate
#Install Toil in the virtual environment
python3 -m pip install toil[all]
#Go back to deployment guide directory
cd ~/deployment-guide/scripts/processing/oapip
```{{exec}}

Toil is already capable of running [OGC Best Practices for Earth Observation Application Pakcage](https://docs.ogc.org/bp/20-089r1.html) applications, which are the ones the EOEPCA Building Block [OGC Process API](https://ogcapi.ogc.org/processes/) interface supports for execution.

We will go in more details about such applications later in the tutorial, in the mean time, we will just test now that Toil works correctly by running one of these example applications

```
source /opt/toil/venv/bin/activate
jobid=$(uuidgen)
mkdir -p /opt/toil/toil_storage/example/{work_dir,job_store}
cat <<EOF > /opt/toil/toil_storage/example/work_dir/$jobid.params.yaml
fn: resize
url: https://eoepca.org/media_portal/images/logo6_med.original.png
size: 50%
EOF
toil-cwl-runner \
    --batchSystem htcondor \
    --workDir /opt/toil/toil_storage/example/work_dir \
    --jobStore /opt/toil/toil_storage/example/job_store/$jobid \
    examples/convert-url-app.cwl#convert-url \
    /opt/toil/toil_storage/example/work_dir/$jobid.params.yaml
```{{exec}}

Now that Toil works correctly, we can install and start the Toil WES service, via

```
docker run -d --restart=always \
    --name toil-wes-rabbitmq \
    -p 127.0.0.1:5672:5672 rabbitmq:3.9.5
celery --broker=amqp://user:bitnami@127.0.0.1:5672// \
    -A toil.server.celery_app worker \
    --loglevel=INFO
TOIL_WES_BROKER_URL=amqp://user:bitnami@127.0.0.1:5672//  toil server \
    --opt=--batchSystem=htcondor \
    --opt=--docker
```{{exec}}

