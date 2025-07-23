Now you have completed the deployment of the EOEPCA MLOps component we can add there some sample training datasets and AI models.

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

What we can do is to create a new dataset for AI traning, which can be done via the Gitlab by [creating a new project]({{TRAFFIC_HOST1_8080}}/projects/new#blank_project). We give to it the `wine-dataset` name, and we uncheck *Initialize this project with a README*.

After the creation is complete, you can go to the [project Settings/General]({{TRAFFIC_HOST1_8080}}/root/wine-dataset/edit), add `sharinghub:dataset` to the "Project Topics" and save the changes.

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

If we go to the SharingHub we will find the new dataset in the [datasets tab]({{TRAFFIC_HOST1_80}}/#/dataset).

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

If we go to the [SharingHub]({{TRAFFIC_HOST1_80}}/) we will find the new model in the [AI model tab]({{TRAFFIC_HOST1_80}}/#/ai-model).
