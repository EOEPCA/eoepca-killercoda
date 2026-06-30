To configure a [Toil WES interface](https://toil.readthedocs.io/en/master/running/server/wes.html) on our HPC cluster, we need first to install the Toil software.

Toil standard installation is performed as a Python virtual environment in a folder accessible to all the HPC computing nodes. This way the computing nodes will seamlessly start it.

Toil will also require, for coordinating the jobs execution, a working folder accessible from all the computing nodes for storing the job storage directories.

In our tutorial HPC environment, the home of the `ubuntu` user is shared across the HPC computing nodes, thus we create in it the Toil virtual environment and jobs storage directories.

```
mkdir -p ~/toil ~/toil/storage
python3 -m venv --prompt toil ~/toil/venv
```{{exec}}

We can now enter the virtual environment and install Toil with HTCondor support via pip:

```
source ~/toil/venv/bin/activate
python3 -m pip install \
  'toil[cwl,htcondor,server,aws]==9.3.0' \
  htcondor
```{{exec}}

The version is pinned because Toil 9.3.0 has been validated with the WES workflow and dependencies used by this workshop.

Check the installed version:

```
toil --version
```{{exec}}

Now all the computing nodes can access Toil from the `ubuntu` user home. We will verify in the next step that Toil is working properly.
