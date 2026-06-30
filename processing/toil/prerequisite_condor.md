An HPC cluster is required for the EOEPCA Processing Building Block to submit processing jobs to it.

This HPC cluster needs to provide:

- support for container execution, such as [Docker](https://www.docker.com/) or [Apptainer/Singularity](https://apptainer.org/);
- internet access from the computing nodes for container and data retrieval, unless applications point to locally accessible registries and data repositories; and
- a [Toil WES interface](https://toil.readthedocs.io/en/master/running/server/wes.html), or access to a submission node implementing one of the [HPC environments](https://toil.readthedocs.io/en/latest/running/hpcEnvironments.html) supported by Toil, such as Grid Engine, Slurm, PBS, LSF, or HTCondor.

In this tutorial, we assume that a Toil WES interface is not already available, but that we have an HPC cluster providing [HTCondor](https://research.cs.wisc.edu/htcondor/), Docker support, and internet access. We will install Toil WES ourselves.

This HPC environment is represented by the `ubuntu` user on this machine. Log in as that user:

```
su - ubuntu
```{{exec}}

Check that HTCondor is accessible:

```
condor_status
```{{exec}}

The output should include `slot1@controlplane` in the `Unclaimed` and `Idle` state, which means the execution slot is available.

In the next steps, we will install Toil and expose its WES interface on this HPC environment.
