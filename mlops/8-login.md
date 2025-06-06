Now press the login button in the top right, we will give you an API key that you can use with our Gitlab instance.

**Locate Your Project**

- Click the **AI Models** category (or the category you used), or visit: `${INGRESS_HOST}/ui/#/ai-model`
- After clicking the **AI Models** card, You should see the new project (`mlops-test-project`) in the listing.

#### 2.3 MLflow Setup & Training

7. **Obtain the MLflow Tracking URI**

- In SharingHub, open your project details.

- Click the **MLflow** link in the top-right corner.
    
- The link will resemble:
    
```http
http://${INGRESS_HOST}/mlflow/root/mlops-test-project/tracking/
```
    
- Set the HTTPS version as an environment variable:

```bash
export MLFLOW_TRACKING_URI="https://${INGRESS_HOST}/mlflow/root/mlops-test-project/tracking/"
```

- We will give you a token to use with MLflow. Paste it in here.

```bash
export MLFLOW_TRACKING_TOKEN="<YOUR-TOKEN>"
```
        
9. **Run a Simple MLflow Experiment**

Set up your environment:

```bash
apt install python3.12-venv --yes
python -m venv venv
source venv/bin/activate
pip install mlflow scikit-learn
```

Run the provided example script located in the `data/` directory of `deployment-guide/scripts/mlops`:

```bash
cd data/
python example-script.py
```

- This script will:
- Load the `data/wine-quality.csv` dataset.
- Train a simple model.
- Log parameters, metrics, and the model into MLflow.