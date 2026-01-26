to test Toil is correctly installed, we will use a [OGC Best Practices for Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html) applications, which are the ones the EOEPCA Building Block [OGC Process API](https://ogcapi.ogc.org/processes/) interface supports for execution.

We will go in more details about such applications later in the tutorial, in the mean time, we will just test now that Toil works correctly by running one of these example applications

Let's download the example application via

```
wget https://github.com/EOEPCA/deployment-guide/raw/refs/heads/main/scripts/processing/oapip/examples/convert-url-app.cwl
```{{exec}}

now to execute a Toil job we ensure that we have the toil environment enabled

```
source ~/toil/venv/bin/activate
```{{exec}}

create an ID for our job

```
sudo apt-get install uuid-runtime
jobid=$(uuidgen)
```{{exec}}

write the parameters for our job execution

```
mkdir -p ~/toil/storage/test/{work_dir,job_store}
cat <<EOF > ~/toil/storage/test/work_dir/$jobid.params.yaml
fn: resize
url: https://eoepca.org/media_portal/images/logo6_med.original.png
size: 50%
EOF
```{{exec}}

and then execute the application via Toil

```
toil-cwl-runner \
    --batchSystem htcondor \
    --workDir ~/toil/storage/test/work_dir \
    --jobStore ~/toil/storage/test/job_store/$jobid \
    convert-url-app.cwl#convert-url \
    ~/toil/storage/test/work_dir/$jobid.params.yaml
```{{exec}}

If all works correctly, at the end of the processing we will see a JSON text which represents the processing output STAC Item. 
You can now delete the test folder

```
rm -rf ~/toil/storage/test
```{{exec}}

Now that we know Toil works correctly, we will proceed to install and start the Toil WES service in the next step
