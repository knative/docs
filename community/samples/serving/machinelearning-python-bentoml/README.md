A simple machine learning model with API serving that is written in python and
using [BentoML](https://github.com/bentoml/BentoML). BentoML is an open source
framework for high performance ML model serving, which supports all major machine
learning frameworks including Keras, Tensorflow, PyTorch, Fast.ai, XGBoost and etc.

This sample will walk you through the steps of creating and deploying a machine learning
model using python. It will use BentoML to package a classifier model trained
on the Iris dataset. Afterward, it will create a container image and
deploy the image to Knative.

Knative deployment guide with BentoML is also available in the
[BentoML documentation](https://docs.bentoml.org/en/latest/deployment/knative.html)

## Before you begin

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../../docs/install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured. Docker Hub will be used for a container registry).
- Python 3.6 or above installed and running on your local machine.
  - Install `scikit-learn` and `bentoml` packages:

    ```shell
    pip install scikit-learn
    pip install bentoml
    ```

## Recreating sample code

Run the following code on your local machine, to train a machine learning model and deploy it
as API endpoint with KNative Serving.

1. BentoML creates a model API server, via prediction service abstraction. In
  `iris_classifier.py`, it defines a prediction service that requires a scikit-learn
  model, asks BentoML to figure out the required pip dependencies, also defines an
  API, which is the entry point for accessing this machine learning service.

    {{% readfile file="iris_classifier.py" %}}

2. In `main.py`, it uses the classic
  [iris flower data set](https://en.wikipedia.org/wiki/Iris_flower_data_set)
  to train a classification model which can predict the species of an iris flower with
  given data and then save the model with BentoML to local disk.

    {{% readfile file="main.py" %}}

    Run the `main.py` file to train and save the model:

    ```shell
    python main.py
    ```

3. Use BentoML CLI to check saved model's information.

    ```shell
    bentoml get IrisClassifier:latest
    ```

    Example:

    ```shell
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

4. Test run API server. BentoML can start an API server from the saved model. Use
  BentoML CLI command to start an API server locally and test it with the `curl` command.

    ```shell
    bentoml serve IrisClassifier:latest
    ```

    In another terminal window, make `curl` request with sample data to the API server
    and get prediction result:

    ```shell
    curl -v -i \
    --header "Content-Type: application/json" \
    --request POST \
    --data '[[5.1, 3.5, 1.4, 0.2]]' \
    127.0.0.1:5000/predict
    ```

## Building and deploying the sample

BentoML supports creating an API server docker image from its saved model directory, where
a Dockerfile is automatically generated when saving the model.

1. To build an API model server docker image, replace `{username}` with your Docker Hub
  username and run the following commands.

    ```shell
    # jq might not be installed on your local system, please follow jq install
    # instruction at https://stedolan.github.io/jq/download/
    saved_path=$(bentoml get IrisClassifier:latest -q | jq -r ".uri.uri")

    # Build the container on your local machine
    docker build - t {username}/iris-classifier $saved_path

    # Push the container to docker registry
    docker push {username}/iris-classifier
    ```

2. In `service.yaml`, replace `{username}` with your Docker hub username, and then deploy
  the service to Knative Serving with `kubectl`:

    {{% readfile file="service.yaml" %}}

    ```shell
    kubectl apply --filename service.yaml
    ```

3. Now that your service is created, Knative performs the following steps:

    - Create a new immutable revision for this version of the app.
    - Network programming to create a route, ingress, service, and load
      balance for your application.
    - Automatically scale your pods up and down (including to zero active
      pods).

4. Run the following command to find the domain URL for your service:

    ```shell
    kubectl get ksvc iris-classifier --output=custom-columns=NAME:.metadata.name,URL:.status.url

    NAME              URL
    iris-classifier   http://iris-classifer.default.example.com
    ```

5. Replace the request URL with the URL return in the previous command, and execute the
  command to get prediction result from the deployed model API endpoint.

    ```shell
    curl -v -i \
      --header "Content-Type: application/json" \
      --request POST \
      --data '[[5.1, 3.5, 1.4, 0.2]]' \
      http://iris-classifier.default.example.com/predict

    [0]
    ```

## Removing the sample app deployment

To remove the application from your cluster, delete the service record:

  ```shell
  kubectl delete --filename service.yaml
  ```
