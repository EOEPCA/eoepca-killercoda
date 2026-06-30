To test Toil is correctly installed, we will use an [OGC Best Practice for Earth Observation Application Package](https://docs.ogc.org/bp/20-089r1.html) application, which is the type of application the EOEPCA Building Block [OGC Process API](https://ogcapi.ogc.org/processes/) interface supports for execution.

We will go into more detail about such applications later in the tutorial. In the meantime, we will test that Toil works correctly by running an example application.

Download the example application from the same **eoepca-2.0** Deployment Guide release used by this tutorial:

```
cd ~
curl --fail --location --show-error \
  --output convert-url-app.cwl \
  https://raw.githubusercontent.com/EOEPCA/deployment-guide/eoepca-2.0/scripts/processing/oapip/examples/convert-url-app.cwl
```{{exec}}

To execute a Toil job, ensure that the Toil environment is enabled and create an ID for the job:

```
source ~/toil/venv/bin/activate
jobid="$(uuidgen)"
echo "Job ID: $jobid"
```{{exec}}

Create the work and job-store directories:

```
mkdir -p ~/toil/storage/test/{work_dir,job_store}
```{{exec}}

Write the parameters for the job execution:

```
cat <<EOF > ~/toil/storage/test/work_dir/$jobid.params.yaml
fn: resize
url: https://raw.githubusercontent.com/github/explore/main/topics/kubernetes/kubernetes.png
size: 50%
EOF
```{{exec}}

Then execute the application via Toil:

```
toil-cwl-runner \
  --batchSystem htcondor \
  --workDir ~/toil/storage/test/work_dir \
  --jobStore ~/toil/storage/test/job_store/$jobid \
  convert-url-app.cwl#convert-url \
  ~/toil/storage/test/work_dir/$jobid.params.yaml
```{{exec}}

If everything works correctly, Toil finishes successfully and prints a JSON description of the output directory, including the resized PNG and its STAC metadata.

You can now delete the test folder:

```
rm -rf ~/toil/storage/test
```{{exec}}

Now that we know Toil works correctly, we will install and start the Toil WES service in the next step.
