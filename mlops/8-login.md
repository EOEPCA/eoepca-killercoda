Now press the login button in the top right, we will give you an API key that you can use with our Gitlab instance.


6. **Locate Your Project**
    
    - Click the **AI Models** category (or the category you used), or visit:  
        `https://sharinghub.${INGRESS_HOST}/ui/#/ai-model`

    ![SharingHub Models](../img/mlops/models.jpeg)  


    - After clicking the **AI Models** card, You should see the new project (`mlops-test-project`) in the listing.
    
    ![SharingHub Project Detail](../img/mlops/model.jpeg)
    
    _If you do not see your project, double-check that the GitLab topic matches the configuration in `sharinghub/generated-values.yaml` (under `config.stac.categories.ai-model.gitlab_topic`)._
    

#### 2.3 MLflow Setup & Training

7. **Obtain the MLflow Tracking URI**
    
    - In SharingHub, open your project details.
        
    - Click the **MLflow** link in the top-right corner.
        
        ![MLFlow Button](../img/mlops/mlflow-button.jpeg)
        
    - The link will resemble:
        
        ```
        http://sharinghub.${INGRESS_HOST}/mlflow/root/mlops-test-project/tracking/
        ```
        
    - Set the HTTPS version as an environment variable:
        
        ```bash
        export MLFLOW_TRACKING_URI="https://sharinghub.${INGRESS_HOST}/mlflow/root/mlops-test-project/tracking/"
        ```
        
8. **Authenticate and Retrieve a Token**
    
    - In GitLab, navigate to your project's Access Tokens page:  
        `https://gitlab.${INGRESS_HOST}/mlops-test-project/-/settings/access_tokens`
        
    - Click **Add new token**.
        
    - Create a token with the **Developer** role and the scopes `read_api, api`.
        
        ![Token](../img/mlops/token.jpeg)
        
    - Set the token as an environment variable:
        
        ```bash
        export MLFLOW_TRACKING_TOKEN="<YOUR-TOKEN>"
        ```
        
9. **Run a Simple MLflow Experiment**
    
    > It is assumed that a python virtual environment is established for the following steps.<br>
    > For example, using the `venv` module...
    > ```bash
    > python -m venv venv
    > source venv/bin/activate
    > ```

    - Ensure you have the required packages:
        
        ```bash
        pip install mlflow scikit-learn
        ```
        
    - Run the provided example script located in the `data/` directory of `deployment-guide/scripts/mlops`:
        
        ```bash
        cd data/
        python example-script.py
        ```
        
    - This script will:
        - Load the `data/wine-quality.csv` dataset.
        - Train a simple model.
        - Log parameters, metrics, and the model into MLflow.