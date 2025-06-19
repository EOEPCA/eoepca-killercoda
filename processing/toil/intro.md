Welcome to the EOEPCA Processing Building Block, [OGC Process API](https://ogcapi.ogc.org/processes/), Toil High Performance Computing (HPC) engine tutorial!

EOEPCA provides different data processing solutions tailored to different use cases. In general, bulk data processing and systematic processing operations are performed using the [OGC Process API](https://ogcapi.ogc.org/processes/) interface, while interactive data processing tasks and data analytics is performed via the [OpenEO API](https://api.openeo.org/) interface.

This is anyway not a given, and a lot will depend on the different use-cases and preferences of the user communities. EOEPCA allows in any case to deploy, at the same time and sharing the same infrastructure resources, both [OGC Process API](https://ogcapi.ogc.org/processes/) and [OpenEO API](https://api.openeo.org/) interfaces.

For the OGC Process API interface, different "execution engines" are available, allowing to submit data processing jobs to different backends. At the time, [Argo workflows](./argo), K8S jobs (via Calrissian) or HPC jobs (via [Toil](./toil)) are supported.

This tutorial will focus on deploying an [OGC Process API](https://ogcapi.ogc.org/processes/) interface, via the [Zoo software](https://zoo-project.org/), submitting data processing jobs to a Toil Workflow Execution Service HPC cluster via [Toil](https://toil.readthedocs.io/en/master/running/server/wes.html) cookiecutter Zoo template.

Note that this tutorial assumes a generic knowledge of EOEPCA and its pre-requisites. If you did not already, it is then strongly suggested to follow the <a href="../intro" target="_blank" rel="noopener noreferrer">EOEPCA introduction tutorials</a> before continuing with this tutorial.
