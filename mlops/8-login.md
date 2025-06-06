Now, press the **Login** button in the top right. 

---

### **Locate Your Project**

1. Click the **AI Models** category (or the category you used), or go directly to:  
`${INGRESS_HOST}/ui/#/ai-model`
2. Click the **AI Models** card.  
You should see your new project (`mlops-test-project`) in the list.

---

### **2.3 MLflow Setup & Training**

#### **Step 1: Get the MLflow Tracking URI**

- In SharingHub, open your project details.
- Click the **MLflow** link in the top-right corner.
- The link will look like this:

```http
http://${INGRESS_HOST}/mlflow/root/mlops-test-project/tracking/
```

- Set the HTTPS version as an environment variable:

```bash
export MLFLOW_TRACKING_URI="https://${INGRESS_HOST}/mlflow/root/mlops-test-project/tracking/"
```

- You’ll be given a token for MLflow. Set it as an environment variable:

```bash
export MLFLOW_TRACKING_TOKEN="<YOUR-TOKEN>"
```

---

#### **Step 2: Run a Simple MLflow Experiment**

1. **Set up your Python environment:**

```bash
apt install python3.12-venv --yes
python -m venv venv
source venv/bin/activate
pip install mlflow scikit-learn
```{{exec}}

2. **Run the example script:**

- Go to the `data/` directory inside `deployment-guide/scripts/mlops`:

    ```bash
    cd data/
    python example-script.py
    ```{{exec}}

- The script will:
    - Load the `data/wine-quality.csv` dataset
    - Train a simple model
    - Log parameters, metrics, and the model to MLflow

---