# Usage

Navigate to [GitLab]({{TRAFFIC_HOST1_8080}}) and create a new project named `mlops-test-project`.

Add `sharinghub:aimodel` to its tags.

Now go to [SharingHub]({{TRAFFIC_HOST1_80}}) and log in with your GitLab account.

Click the **Show more...* button in the **AI Models** card.

- In the **AI Models** card, click on the `mlops-test-project` project card to open it.
- In the top-right corner, click the **MLflow** link.
- The MLflow Tracking UI will open in a new tab. The URL will look like:

```bash
export MLFLOW_TRACKING_URI="{{TRAFFIC_HOST1_80}}/mlflow/root/mlops-test-project/tracking/"
```{{exec}}

---

In GitLab create an access token

```bash
export MLFLOW_TRACKING_TOKEN="<YOUR-TOKEN>"
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
pip install mlflow scikit-learn
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
