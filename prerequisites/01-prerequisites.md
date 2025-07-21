As specified in the [Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/prerequisites/prerequisites-overview/), the following prerequisites are required or recommended to deploy and run EOEPCA building blocks:

1. **Kubernetes** \[Mandatory\]

   Although some of the software implementation of the EOEPCA Building Blocks may work in bare-metal or VMs, the EOEPCA standards deployment assumes [Kubernetes](https://kubernetes.io/docs/concepts/) is used to manage all the different services and their resources.

   In addition, EOEPCA assumes it is possible to run containers as root (or virtual root) in the cluster, at least for the main EOEPCA services.

   This is already provided by the sandbox platform we are runnning the tutorial on.

2. **Wildcard DNS** \[Optional\]

   The EOEPCA Building Blocks will deploy services accessible via a given domain, exposed by the Ingress Host of the Kubernetes cluster. By default, most Building Block deploy service endpoints as sub-domains of the ingress Host. Thus, the easiest way to map the domain names to the EOEPCA Building Block services is to setup a wildcard DNS entry mapping **.my.domain* to the ingress IP. Note that the use of wildcard DNSes is not recommended in production for security reasons.

   For the purpose of this training and subsequent trainings on individual Building Blocks, we have configured our testbed in a way that the domain names of the required services are mapped locally via the `/etc/hosts` file and the `coredns` service in the Kubernetes cluster

3. **Storage** \[Recommended\]

   All of EOEPCA Building Blocks, with very few exceptions will require a [Storage Class](https://kubernetes.io/docs/concepts/storage/storage-classes/) setup in the Kubernetes Cluster for persistence of data.

   Some EOEPCA Building Blocks, particularly those involved in processing (e.g. the CWL Processing Engine), require shared storage with [ReadWriteMany](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) access mode. This allows to create volumens to which multiple pods can read and write concurrently.

   For the purpose of this training and subsequent training on individual Building Blocks (where required), we will configure the HostPath provisioner together with its associated `standard` storage class.

4. **Ingress controller** \[Mandatory\]

   EOEPCA+ requires an ingress controller to route external traffic into the platform’s services. The ingress controller recommended by the EOEPCA Develpoment Guide is [APISIX](https://apisix.apache.org/) which is also mandatory if the EOEPCA's IAM (Identity and Access Management) is to be used. However, for other purposes such as a development instance or when a deployment is fully open or has its own authentication and authorization method, [NGINX](https://nginx.org/) ingress controller is supported.

   In the training we are going to deploy and use NGINX in most tutorials, where we do not need authentication, and APISIX if we need it.

5. **Load Balancer** \[Recommended\]

   Typically, a load balancer provided with the cloud platform where EOEPCA is being installed, must be used and configured with the ingress controller to provide external access to individual components.

   This is not going to be necessary in our trainings since we are using a very simplified Kubernetes configuration with only one node.
   
6. **Cert-Manager** \[Recommended\]

   Cert-Manager is an essential component for securing communication in EOEPCA, both internally between the component and externally with user clients. In EOEPCA it is typically configured with the [LetsEncrypt](https://letsencrypt.org/) ACME service (Automated Certificate Management Environment) and can autimatically issue, sign (by LetsEncrtypt) and renew TLS certificates. However, for cases when LetsEncrypt cannot be used there is an alternative method, and there is also a possibility not to install and use Cert-Manager at all in which case the traffic will not be encrypted.

   For the purpose of this training we will install Cert-Manager. However, to make things simple, in trainings on individual Building Blocks it will not be used.

7. **S3 Object storage** \[Recommended\]

   Most if not all EOEPCA components will require a form of object storage for handling data input and output. An S3-compatible storage, like the one provided by [MinIO](https://min.io/) or generic cloud providers is thus strongly recommended. 

   In EOEPCA, as default, MinIO will serve as the local object storage backend for various services. There is anyway the possibility to configure an alternative S3-compatible object storage solution instead of MinIO e.g. use an external S3 storage provided by the cloud platform.

In the following steps we will do in more details about the prerequisites above.
