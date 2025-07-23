```bash
python -m venv venv
source venv/bin/activate
pip install mlflow==2.14.2 setuptools pystac
```{{exec}}

```
export MLFLOW_TRACKING_TOKEN=$(cat ~/gitlab-access-token)
export MLFLOW_TRACKING_URI="$(sed 's|PORT|80|' /etc/killercoda/host)/mlflow/root/wine-model/tracking/"
export LOGNAME=experiment1
export INPUT_STAC_DATASET="$(sed 's|PORT|80|' /etc/killercoda/host)/api/stac/collections/dataset/items/root/wine-dataset"
```{exec}}

**Run the example Machine Learning script:**

```bash
cd data/
python example-script.py
```{{exec}}

The script will:
- Load a dataset
- Train a simple model
- Log parameters, metrics, and the model to MLflow
