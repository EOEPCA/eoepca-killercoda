to configure a [Toil WES interace](https://toil.readthedocs.io/en/master/running/server/wes.html) on our HPC cluster, we need first to install the Toil software.

Toil standard installation is performed as a python virtual environment in a folder accessible to all the HPC computing nodes.This way the computing nodes will seamlessly start it.

Toil will also require for coordinating the jobs execution a running folder accessible from all the computing nodes, for storing the jobs storage directories.

In our tutorial HPC environment, the home of the `ubuntu` user is shared across the HPC computing nodes, thus we create in it the Toil virtual environment and jobs storage directories

```
[[ "`id -nu`" != "ubuntu" ]] && su - ubuntu
mkdir -p ~/toil ~/toil/storage
python3 -m venv --prompt toil ~/toil/venv
```{{exec}}

we now can enter the virtual environment and install Toil with HTCondor support via pip

```
source ~/toil/venv/bin/activate
python3 -m pip install toil[cwl,htcondor,server,aws] htcondor
```{{exec}}

now all the computing nodes can access toil from the `ubuntu` user home

we will now verify in the next step that Toil is working properly
