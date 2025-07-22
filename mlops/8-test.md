Now you have completed the deployment of the EOEPCA MLOps component and you can test your installation.

First, we can go to the Gitlab and [Create an access token]({{TRAFFIC_HOST1_8080}}/-/user_settings/personal_access_tokens), click on "Add new token" and, name it `myuser` and select the `api`{{}}, `read_api`{{}}, `read_user`{{}}, `read_repository`{{}}, `write_repository`{{}} rights and click the "Save" button. Copy the generated access token and then run the command below (pasting the token for saving in your environment)

```
read -p "You personal access token: " MLFLOW_TRACKING_TOKEN; echo "$MLFLOW_TRACKING_TOKEN" > ~/gitlab-access-token
```{{exec}}

Setup your name via

```
git config --local user.name "Administrator"
git config --local user.email "gitlab_admin_test@example.com"
```{{exec}}

and we are all ready to test our EOEPCA MLOps.

First thing first, the EOEPCA MLOps component uses the Gitlab as main repository

Now you can go to the Gitlab and [Create a new project]({{TRAFFIC_HOST1_8080}}/projects/new#blank_project) named `wine-dataset`. Note that creation of a new project in our basic sandbox environment may take a few minute, do not stop the request.

Go to the [project Settings/General]({{TRAFFIC_HOST1_8080}}/root/mlops-test-project/edit), add `sharinghub:dataset` to the "Project Topics" and save the changes.

```
cd ~
git clone https://root:`cat ~/gitlab-access-token`@`sed 's|.*://\(.*\)PORT\(.*\)|\18080\2|' /etc/killercoda/host`/root/wine-dataset.git
cd wine-dataset
git config --local user.name "Administrator"
git config --local user.email "gitlab_admin_test@example.com"
```{{exec}}

```
git switch --create main
cp -r ~/deployment-guide/scripts/mlops/data/wine-dataset/* ./
git add .
git commit -m "wine dataset"
git push
```{{exec}}


Now you can go to the Gitlab and [Create a new project]({{TRAFFIC_HOST1_8080}}/projects/new#blank_project) named `mlops-test-project`. Note that creation of a new project in our basic sandbox environment may take a few minute, do not stop the request.

Go to the [project Settings/General]({{TRAFFIC_HOST1_8080}}/root/mlops-test-project/edit), add `sharinghub:aimodel` to the "Project Topics" and save the changes.

Now we have created an AI model repository. You can see it in the [SharingHub]({{TRAFFIC_HOST1_80}}) after logging in with your GitLab account if you click on the [AI Models]({{TRAFFIC_HOST1_80}/#/ai-model) card in the top-left corner.


As you can see, our project is empty, we need to fill it in. To do so, back to the [gitlab]({{TRAFFIC_HOST1_8080}}/root/mlops-test-project), we can see our gitlab path and clone it locally via

```
cd ~
git clone https://root:`cat ~/gitlab-access-token`@`sed 's|.*://\(.*\)PORT\(.*\)|\18080\2|' /etc/killercoda/host`/root/mlops-test-project.git
cd mlops-test-project
git config --local user.name "Administrator"
git config --local user.email "gitlab_admin_test@example.com"
```{{exec}}

We can now fill it in using the sample "Wine model" contained in the deployment guide

```
git switch --create main
cp -r ~/deployment-guide/scripts/mlops/data/wine-model-main/.* ~/deployment-guide/scripts/mlops/data/wine-model-main/* ./
git add .
git commit -m "wine model"
git push
```{{exec}}

We can now go back to the [SharingHub AI Models]({{TRAFFIC_HOST1_80}/#/ai-model) and see that our wine model repository is 

wget https://gitlab.develop.eoepca.org/sharinghub-test/wine-model/-/archive/main/wine-model-main.tar.gz
tar xvzf wine-model-main.tar.gz
mv wine-model-main ~/deployment-guide/scripts/mlops/data/wine-model
rm wine-model-main.tar.gz
wget https://gitlab.develop.eoepca.org/sharinghub-test/wine-dataset/-/archive/main/wine-dataset-main.tar.gz
tar xvzf wine-dataset-main.tar.gz
mv wine-dataset-main ~/deployment-guide/scripts/mlops/data/wine-dataset
rm wine-dataset-main.tar.gz

Now we download the sample "Wine model" 

- In the **AI Models** card, click on the `mlops-test-project` project card to open it.
- In the top-right corner, click the **MLflow** link.
- The MLflow Tracking UI will open in a new tab. The URL will look like:

```bash
export MLFLOW_TRACKING_URI="{{TRAFFIC_HOST1_30336}}/root/mlops-test-project/tracking/"
```{{exec}}

---

In GitLab [create an access token]({{TRAFFIC_HOST1_8080}}/-/user_settings/personal_access_tokens)

```bash
read -p "Insert tracking token: " MLFLOW_TRACKING_TOKEN; echo "$MLFLOW_TRACKING_TOKEN" > ~/gitlab-access-token
```

---

#### **Step 2: Run a Simple MLflow Experiment**

**Set up your Python environment:**

```bash
apt install python3.12-venv --yes
```{{exec}}

```bash
python -m venv venv
source venv/bin/activate
pip install mlflow==2.14.2 scikit-learn
```{{exec}}

**Run the example Machine Learning script:**

```bash
cd data/
python example-script.py
```{{exec}}

The script will:
- Load a dataset
- Train a simple model
- Log parameters, metrics, and the model to MLflow
