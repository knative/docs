# Python BentoML sample

A simple machine learning model with API serving that is written in Python and
using [BentoML](https://github.com/bentoml/BentoML).

BentoML is an open source framework for high performance ML model serving, which supports all major machine learning frameworks including Keras, Tensorflow, PyTorch, Fast.ai, and XGBoost.

This sample walks you through the steps of creating and deploying a machine learning model using Python. It uses BentoML to package a classifier model that is trained on the Iris dataset, and then creates a container image and
deploy the image to Knative.

Knative deployment guide with BentoML is also available in the [BentoML documentation](https://docs.bentoml.org/en/latest/deployment/knative.html).

## Prerequisites

- You must have a Kubernetes cluster with Knative installed. See the [installation instructions](../../../../docs/admin/install/README.md) for more information.
- You must have [Docker](https://www.docker.com) installed and running on your local machine, and a Docker Hub account configured. Docker Hub is used as a container registry.
- You must have Python 3.6 or above installed and running on your local machine.
- You must install the `scikit-learn` and `bentoml` packages:

    ```bash
    pip install scikit-learn
    pip install bentoml
    ```

## About the sample code

### iris_classifier

BentoML creates a model API server by using prediction service abstraction. In the `iris_classifier.py` file, a prediction service is defined, which:

1. Requires a `scikit-learn` model.
1. Asks BentoML to identify the required `pip` dependencies.
1. Defines an API, which is the entry point for accessing this machine learning service.

--8<-- "iris_classifier.py"

### main

In the `main.py` file, the [iris flower data set](https://en.wikipedia.org/wiki/Iris_flower_data_set) is used to train a classification model, which can predict the species of an iris flower with given data, and then saves the model to the local disk by using BentoML.

--8<-- "main.py"

## Procedure

1. Run the `main.py` file to train and save the model:

    ```bash
    python main.py
    ```

1. Run the following `bentoml` CLI command to check saved model's information:

    ```bash
    bentoml get IrisClassifier:latest
    ```

    Example output:

    ```bash
    > bentoml get IrisClassifier:latest
    {
      "name": "IrisClassifier",
      "version": "20200305171229_0A1411",
      "uri": {
        "type": "LOCAL",
        "uri": "/Users/bozhaoyu/bentoml/repository/IrisClassifier/20200305171229_0A1411"
      },
      "bentoServiceMetadata": {
        "name": "IrisClassifier",
        "version": "20200305171229_0A1411",
        "createdAt": "2020-03-06T01:12:49.431011Z",
        "env": {
          "condaEnv": "name: bentoml-IrisClassifier\nchannels:\n- defaults\ndependencies:\n- python=3.7.3\n- pip\n",
          "pipDependencies": "bentoml==0.6.2\nscikit-learn",
          "pythonVersion": "3.7.3"
        },
        "artifacts": [
          {
            "name": "model",
            "artifactType": "SklearnModelArtifact"
          }
        ],
        "apis": [
          {
            "name": "predict",
            "handlerType": "DataframeHandler",
            "docs": "BentoService API",
            "handlerConfig": {
              "orient": "records",
              "typ": "frame",
              "input_dtypes": null,
              "output_orient": "records"
            }
          }
        ]
      }
    }
    ```

1. Test run the API server. BentoML can start an API server from the saved model. Run the following `bentoml` CLI command to start an API server locally:

    ```bash
    bentoml serve IrisClassifier:latest
    ```

1. Test the API server by using the `curl` command. In a new terminal window, run the following command to make a `curl` request to the API server that uses sample data to get prediction results:

    ```bash
    curl -v -i \
    --header "Content-Type: application/json" \
    --request POST \
    --data '[[5.1, 3.5, 1.4, 0.2]]' \
    127.0.0.1:5000/predict
    ```

1. BentoML supports creating an API server docker image from its saved model directory, where a Dockerfile is automatically generated when saving the model.

    To build an API model server Docker image, replace `{username}` with your Docker Hub username and run the following commands:

    ```bash
    # jq might not be installed on your local system, please follow jq install
    # instruction at https://stedolan.github.io/jq/download/
    saved_path=$(bentoml get IrisClassifier:latest -q | jq -r ".uri.uri")

    # Build the container on your local machine
    docker build - t {username}/iris-classifier $saved_path

    # Push the container to docker registry
    docker push {username}/iris-classifier
    ```

1. In sample `service.yaml` file, replace `{username}` with your Docker hub username, and then deploy the Service to Knative Serving by using `kubectl`:

    {{% readfile file="service.yaml" %}}

    ```bash
    kubectl apply -fe service.yaml
    ```

1. After the Service has been created, Knative performs the following steps:

    - Creates a new immutable revision for this version of the app.
    - Carries out network programming to create a route, ingress, service, and load balancer for your application.
    - Automatically scales pods up and down, including scaling to zero when no pods are receiving requests.

1. Run the following command to find the domain URL for your Knative Service:

    ```bash
    kubectl get ksvc iris-classifier --output=custom-columns=NAME:.metadata.name,URL:.status.url
    ```

    Example output:

    ```
    NAME              URL
    iris-classifier   http://iris-classifer.default.example.com
    ```

1. Replace the request URL with the URL that was returned from the previous command, and run the following command to get a prediction result from the deployed model API endpoint:

    ```bash
    curl -v -i \
      --header "Content-Type: application/json" \
      --request POST \
      --data '[[5.1, 3.5, 1.4, 0.2]]' \
      http://iris-classifier.default.example.com/predict

    [0]
    ```

1. To remove the sample application from your cluster, run the following command:

    ```bash
    kubectl delete -f service.yaml
    ```
