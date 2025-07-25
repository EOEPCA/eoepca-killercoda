To execute our service, we'll create a Python test script. This script will act as a harness, simulating the environment and inputs that would typically be provided by a full ZOO-Project server. 

**In a production scenario**, this script would be replaced by actual service code that interacts with ZOO-Project, but for this scenario, we have limited resources inside of Killercoda, so we'll simulate the environment instead.

Let's create the `test.py` file.

```bash
cat <<EOF > tests/test.py
import os
import unittest

from cookiecutter.main import cookiecutter
from loguru import logger


class TestSimpleService(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        class ZooStub(object):
            def __init__(self):
                self.SERVICE_SUCCEEDED = 3
                self.SERVICE_FAILED = 4

            def update_status(self, conf, progress):
                print(f"Status {progress}")

            def _(self, message):
                print(f"invoked _ with {message}")

        try:
            import zoo
        except ImportError:
            print("Not running in zoo instance")
            zoo = ZooStub()

        os.environ["ARGO_WF_ENDPOINT"] = "http://localhost:2746"
        os.environ["ARGO_WF_TOKEN"] = (
            "eyJhbGciOiJSUzI1NiIsImtpZCI6ImZSUUYycDZNbnI4MTZLeXVFUnpyZk9FcUJGTHdQQzI4SURGdHhQc0pzRXMifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJuczEiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoiYXJnby5zZXJ2aWNlLWFjY291bnQtdG9rZW4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiYXJnbyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjExZjI1NDUxLWE4OGEtNDFkZC1hNGIxLTJlNTM3ZGUyOGU3NiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDpuczE6YXJnbyJ9.dUVo3WCJgoVN5NVh3VVeKw7uF6hE6moCj8Mu5W7ioJ4M_lG_bJ4BZ7XRaJVrQMF--vMQAiNDr-_GSC0R7ItKmRqhafkONy61MeEDz_6u-j0ay4fj8qofgBatnF7lWcVVvNklVZxZ4IGb62SJepAvzerxsz5HhSG8icn9U0cUsyg4Vw_wsHntic-yFY4Eyp6kYSEXO5G2v_0KXLKcpLB41YLfMQaE8cu0ghmE5mFmKkKOf0oDHhLlch-j_K0IpGvXKcjZGlwjiukD1dCL3E6BSHYMutuz4n27Bg62nf3rZBErUkJB2GRjN-tKIoYMrEuwyEbv7TSuCeqHGyfWn3Tu0A"
        )
        os.environ["ARGO_WF_SYNCHRONIZATION_CM"] = (
            "semaphore-argo-cwl-runner-stage-in-out"
        )
        os.environ["ARGO_CWL_RUNNER_TEMPLATE"] = "argo-cwl-runner-stage-in-out"
        os.environ["DEFAULT_VOLUME_SIZE"] = "1Gi"
        os.environ["STORAGE_CLASS"] = "standard"

        cls.zoo = zoo
        
        conf = {}
        conf["lenv"] = {"message": "", "Identifier": "simple-showcase", "usid": "abc-1234"}
        conf["tmpPath"] = "/tmp"
        conf["main"] = {"tmpUrl": "http://localhost/logs/"}
        conf["auth_env"] = {"user": "ns1"}
        conf["additional_parameters"] = {
            "s3_bucket": "results",
            "sub_path": conf["lenv"]["usid"],
            "region_name": "it-rom",
            "aws_secret_access_key": "minio-admin",
            "aws_access_key_id": "minio-admin",
            "endpoint_url": "http://minio.ns1.svc.cluster.local:9000",
        }
        cls.conf = conf

        cookiecutter_values = {
            "service_name": "simple_showcase",
            "workflow_id": "simple-showcase",
        }

        template_folder = f"{os.path.dirname(__file__)}/.."
        service_tmp_folder = "tests/"

        cookiecutter(
            template_folder,
            extra_context=cookiecutter_values,
            output_dir=service_tmp_folder,
            no_input=True,
            overwrite_if_exists=True,
        )
        
        # The workflow has no inputs
        inputs = {}
        cls.inputs = inputs
        
        outputs = {"result_directory": {"value": ""}}
        cls.outputs = outputs

    def test_execution(self):
        from tests.simple_showcase.service import simple_showcase
        
        exit_code = simple_showcase(self.conf, self.inputs, self.outputs)

        self.assertEqual(exit_code, self.zoo.SERVICE_SUCCEEDED)
EOF
```{{exec}}
