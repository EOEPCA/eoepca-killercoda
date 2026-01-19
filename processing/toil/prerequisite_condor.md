an High Performance Computing (HPC) cluster is required for the EOEPCA's Processing Building Block to submit processing to it.

This HPC cluster needs to provide the following:
 - support to containers execution, such as [Docker](https://www.docker.com/) or [Apptainer/Singularity](https://apptainer.org/)
 - internet access from the computing nodes for containers and data retreival (in alternative, submitted applications will need to point to localy accessible container registries and data repositories)
 - a [Toil WES interace](https://toil.readthedocs.io/en/master/running/server/wes.html) or, in alternative, access to a submission node implementing one of the [HPC Environments](https://toil.readthedocs.io/en/latest/running/hpcEnvironments.html) interfaces supported by Toil, such as [Grid Engine](http://www.univa.com/oracle), [Slurm](https://www.schedmd.com/), [PBS/Torque/PBS Pro](http://www.adaptivecomputing.com/products/open-source/torque/), [LSF](https://en.wikipedia.org/wiki/Platform_LSF) and [HTCondor](https://research.cs.wisc.edu/htcondor/).

In this tutorial we assume, as this is the most common, that a [Toil WES interace](https://toil.readthedocs.io/en/master/running/server/wes.html) is not available, but we have an HPC Cluster that provides the [HTCondor](https://research.cs.wisc.edu/htcondor/) environment with [Docker](https://www.docker.com/) support and free internet access.

This HPC environment is accessible by the `ubuntu` user installed on this machine.

To check it, you can login as `ubuntu`{{}} user:

```
su - ubuntu
```{{exec}}

and test that our HTCondor is properly accessible via:

```
condor_status
```{{exec}}

> If this returns an error please run:

```
sudo condor_master
```{{exec}}

And wait 5 seconds, then run `condor_status` again.

we will then, in the next steps, proceed to the installation of the Toil software and Toil WES interface on own HPC cluster
