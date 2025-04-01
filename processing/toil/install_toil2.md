to test Toil is correctly installed, we will use a [OGC Best Practices for Earth Observation Application Pakcage](https://docs.ogc.org/bp/20-089r1.html) applications, which are the ones the EOEPCA Building Block [OGC Process API](https://ogcapi.ogc.org/processes/) interface supports for execution.

We will go in more details about such applications later in the tutorial, in the mean time, we will just test now that Toil works correctly by running one of these example applications

Let's download the example application via

```
wget https://github.com/EOEPCA/deployment-guide/raw/refs/heads/main/scripts/processing/oapip/examples/convert-url-app.cwl
```

and execute a Toil job via

```
#Ensure you have the toil environment enabled
source ~/toil/venv/bin/activate
#Create an ID for your job
jobid=$(uuidgen)
#Create working directory and job storage directories for your job in the toil storage
mkdir -p ~/toil/storage/example/{work_dir,job_store}
#Write the parameters of your job execution
cat <<EOF > ~/toil/storage/example/work_dir/$jobid.params.yaml
fn: resize
url: https://eoepca.org/media_portal/images/logo6_med.original.png
size: 50%
EOF
#Execute the OGC Application Package via Toil
toil-cwl-runner \
    --batchSystem htcondor \
    --workDir ~/toil/storage/example/work_dir \
    --jobStore ~/toil/storage/example/job_store/$jobid \
    convert-url-app.cwl#convert-url \
    ~/toil/storage/example/work_dir/$jobid.params.yaml
```{{exec}}

Now that we know Toil works correctly, we will proceed to install and start the Toil WES service in the next step
