```bash
python -m venv venv
source venv/bin/activate
pip install mlflow==2.14.2 setuptools
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
