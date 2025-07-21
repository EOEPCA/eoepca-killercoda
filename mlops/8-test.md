#### Create a model project

Navigate to [GitLab]({{TRAFFIC_HOST1_8080}}).

[Create a new project]({{TRAFFIC_HOST1_8080}}/projects/new#blank_project) named `mlops-test-project`.

Go to the [project Settings]({{TRAFFIC_HOST1_8080}}/root/mlops-test-project/edit), add `sharinghub:aimodel` to the "Project Topics" and save the changes.

Now go to [SharingHub]({{TRAFFIC_HOST1_80}}) and log in with your GitLab account.

Click the [AI Models]({{TRAFFIC_HOST1_80}/#/ai-model) card in the top-left corner.

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
