On your other tab, revisit your temporary Killercoda URL and ensure you can access the MLOps UI.

If it's not accessible, you may need to wait a few minutes for the services to start.

Check the status with 
```bash
kubectl get pods -n sharinghub
```{{exec}}

---

### **Locate Your Project**

Click the **Show more...* button in the **AI Models** card.
You should see the project (`mlops-test-project`) in the list (This is a shared repository in GitLab that was created for this demonstration).

---

### **2.3 MLflow Setup & Training**

#### **Step 1: Get the MLflow Tracking URI**

- In the **AI Models** card, click on the `mlops-test-project` project card to open it.
- In the top-right corner, click the **MLflow** link.
- The MLflow Tracking UI will open in a new tab. The URL will look like:

```
http://${INGRESS_HOST}/mlflow/root/mlops-test-project/tracking/
```

- Set the HTTPS version of the tracking URI as an environment variable:

```bash
export MLFLOW_TRACKING_URI="https://${INGRESS_HOST}/mlflow/root/mlops-test-project/tracking/"
```

- When prompted, copy your MLflow access token (given to you) and set it as an environment variable:

```bash
export MLFLOW_TRACKING_TOKEN="<YOUR-TOKEN>"
```

---

#### **Step 2: Run a Simple MLflow Experiment**

**Set up your Python environment:**

```bash
apt install python3.12-venv --yes
python -m venv venv
source venv/bin/activate
pip install mlflow scikit-learn
```{{exec}}

**Run the example Machine Learning script:**

```bash
cd data/
python example-script.py
```{{exec}}

- The script will:
- Load a dataset
- Train a simple model
- Log parameters, metrics, and the model to MLflow
