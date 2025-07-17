The EOEPCA **MLOps Building Block** provides integrated services for training, managing and deploying machine learning models. It uses three main components:

- [GitLab](https://gitlab.com/) for version control. For the purpose of this demonstration, you'll use a pre-configured GitLab instance.

- [SharingHub](https://github.com/csgroup-oss/sharinghub/) for discovering datasets and ML models.

- [MLflow](https://mlflow.org/) for tracking experiments, metrics and managing ML models.

Before we start, you should note that this tutorial assumes a generic knowledge of EOEPCA pre-requisites (Kubernetes, Object Storage, etc...) and some tools installed on your environment (gomplate, minio client, etc...). If you want to know more about what is needed, for example if you want to replicate this tutorial on your own environment, you can follow the <a href="prerequisites" target="_blank" rel="noopener noreferrer">EOEPCA Pre-requisites</a> tutorial.
