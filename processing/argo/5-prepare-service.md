We'll now use a template to create a ZOO-Project compatible processing service. This template provides the structure for packaging a CWL workflow as a service that can be executed by the `zoo-argowf-runner`.

First, let's clone the service template repository.

```bash
cd ..
git clone https://github.com/lmizzoni/zoo-argo-wf-proc-service-template.git
cd zoo-argo-wf-proc-service-template
```{{exec}}

To run our service, we need a Python environment with a few dependencies. We'll use `venv` to create an isolated environment.

```bash
apt-get update > /dev/null && apt-get install -y python3-venv > /dev/null
```{{exec}}

And now, let's create and activate our virtual environment.

```bash
python3 -m venv env_zoo
source env_zoo/bin/activate
```{{exec}}

Now, with our virtual environment active, we can install the required Python packages.

```bash
pip install -r requirements.txt > /dev/null
pip install -i https://test.pypi.org/simple/ zoo-argowf-runner > /dev/null
```{{exec}}

Our service environment is now all set up. Next, we'll define the actual application to be executed.