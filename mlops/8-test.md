Now you have completed the deployment of the EOEPCA MLOps component and you can test your installation.

First, we can go to the Gitlab and [Create an access token]({{TRAFFIC_HOST1_8080}}/-/user_settings/personal_access_tokens), click on "Add new token" and, name it `mytoken`, and select all rights (the `api`{{}} right) and click the "Save" button. Copy the generated access token and then run the command below (pasting the token for saving in your environment)

```
read -p "You personal access token: " MLFLOW_TRACKING_TOKEN; echo "$MLFLOW_TRACKING_TOKEN" > ~/gitlab-access-token
```{{exec}}

Setup your name via

```
git config --global user.name "Administrator"
git config --global user.email "gitlab_admin_test@example.com"
```{{exec}}

and we are all ready to test our EOEPCA MLOps.

First thing first, the EOEPCA MLOps component uses the Gitlab as main repository for both the training datasets and the AI models. These can be then added as new git project, with appropriate "Project Topics" for SharingHub to discriminate what is a dataset and what is a AI model.

What we can do is to create a new dataset for AI traning, which can be done via the Gitlab by [creating a new project]({{TRAFFIC_HOST1_8080}}/projects/new#blank_project). We give to it the `wine-dataset` name. After the creation is complete (note that that creation of a new project in our basic sandbox environment may take a few minute, do not stop the request), you can go to the [project Settings/General]({{TRAFFIC_HOST1_8080}}/root/wine-dataset/edit), add `sharinghub:dataset` to the "Project Topics" and save the changes.

We can now clone this repository locally (using the access token we saved before),

```
cd ~
git clone https://root:$(cat ~/gitlab-access-token)@$(sed 's|.*://\(.*\)PORT\(.*\)|\18080\2|' /etc/killercoda/host)/root/wine-dataset.git
cd wine-dataset
```{{exec}}

and fill it with our sample Wines dataset

```
git switch --create main
cp -r ~/deployment-guide/scripts/mlops/data/wine-dataset/* ./
git add .
git commit -m "wine dataset"
git push
```{{exec}}

If we go to the [SharingHub]({{TRAFFIC_HOST1_80}}) we will find the new dataset in the [datasets tab]({{TRAFFIC_HOST1_80}}/#/dataset).

We can now create an AI model trained on this dataset, from doing so we again [create a new project]({{TRAFFIC_HOST1_8080}}/projects/new#blank_project). We give to it the `wine-model` name. After the creation is complete (note that that creation of a new project in our basic sandbox environment may take a few minute, do not stop the request), you can go to the [project Settings/General]({{TRAFFIC_HOST1_8080}}/root/wine-model/edit), add `sharinghub:aimodel` to the "Project Topics" and save the changes.


We can now clone this repository locally (using the access token we saved before),

```
cd ~
git clone https://root:$(cat ~/gitlab-access-token)@$(sed 's|.*://\(.*\)PORT\(.*\)|\18080\2|' /etc/killercoda/host)/root/wine-model.git
cd wine-model
```{{exec}}

and fill it with our sample wines model

```
git switch --create main
cp -r ~/deployment-guide/scripts/mlops/data/wine-model/* ./
git add .
git commit -m "wine model"
git push
```{{exec}}

If we go to the [SharingHub]({{TRAFFIC_HOST1_80}}) we will find the new model in the [AI model tab]({{TRAFFIC_HOST1_80}}/#/ai-model).

From the AI model tab, you can then enter from the links the MlFlow. MlFlow is used to track the training and execution of our AI models. If you follow the link

We can now try to run this model using MlFlow.

```
python3 -m venv venv
source venv/bin/activate
pip install mlflow==2.14.2
pip install -r requirements.txt

export MLFLOW_TRACKING_TOKEN="`cat ~/gitlab-access-token`"
./inference.py wine-quality-model.joblib "[[14.23, 1.71, 2.43, 15.6, 127.0, 2.8, 3.06, 0.28, 2.29, 5.64, 1.04]]"
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
