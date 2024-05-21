# Hello World - Python BentoML

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
  [Knative installation instructions](https://knative.dev/docs/install/) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured. Docker Hub will be used for a container registry).
- Python 3.6 or above installed and running on your local machine.
  - Install `scikit-learn` and `bentoml` packages:

    ```bash
    pip install scikit-learn
    pip install bentoml
    ```

## Recreating sample code

Run the following code on your local machine, to train a machine learning model and deploy it
as API endpoint with Knative Serving.

1. BentoML creates a model API server, via prediction service abstraction. In
  `iris_classifier.py`, it defines a prediction service that requires a scikit-learn
  model, asks BentoML to figure out the required pip dependencies, also defines an
  API, which is the entry point for accessing this machine learning service.

    ```python
    import bentoml
    import joblib


    @bentoml.service
    class IrisClassifier:
        iris_model = bentoml.models.get("iris_classifier:latest")

        def __init__(self):
            self.model = joblib.load(self.iris_model.path_of("model.pkl"))

        @bentoml.api
        def predict(self, df):
            return self.artifacts.model.predict(df)
    ```

1. In `main.py`, it uses the classic
  [iris flower data set](https://en.wikipedia.org/wiki/Iris_flower_data_set)
  to train a classification model which can predict the species of an iris flower with
  given data and then save the model with BentoML to local disk.

    ```python
    import joblib
    from sklearn import svm
    from sklearn import datasets

    import bentoml

    if __name__ == "__main__":
        # Load training data
        iris = datasets.load_iris()
        X, y = iris.data, iris.target

        # Model Training
        clf = svm.SVC(gamma='scale')
        clf.fit(X, y)

        with bentoml.models.create("iris_classifier") as bento_model:
            joblib.dump(clf, bento_model.path_of("model.pkl"))
        print(f"Model saved: {bento_model}")
    ```

1. Run the `main.py` file to train and save the model:

    ```bash
    python main.py
    ```

1. Use BentoML CLI to check saved model's information.

    ```bash
    bentoml get iris_classifier:latest
    ```

    Example:

    ```bash
    > bentoml get iris_classifier:latest -o json
    {
      "service": "iris_classifier:IrisClassifier",
      "name": "iris_classifier",
      "version": "ar67rxqxqcrqi7ol",
      "bentoml_version": "1.2.16",
      "creation_time": "2024-05-21T14:40:20.737900+00:00",
      "labels": {
        "owner": "bentoml-team",
        "project": "gallery"
      },
      "models": [],
      "runners": [],
      "entry_service": "IrisClassifier",
      "services": [
        {
          "name": "IrisClassifier",
          "service": "",
          "models": [
            {
              "tag": "iris_sklearn:ml5evdaxpwrqi7ol",
              "module": "",
              "creation_time": "2024-05-21T14:21:17.070059+00:00"
            }
          ],
          "dependencies": [],
          "config": {}
        }
      ],
      "envs": [],
      "schema": {
        "name": "IrisClassifier",
        "type": "service",
        "routes": [
          {
            "name": "predict",
            "route": "/predict",
            "batchable": false,
            "input": {
              "properties": {
                "df": {
                  "title": "Df"
                }
              },
              "required": [
                "df"
              ],
              "title": "Input",
              "type": "object"
            },
            "output": {
              "title": "AnyIODescriptor"
            }
          }
        ]
      },
      "apis": [],
      "docker": {
        "distro": "debian",
        "python_version": "3.11",
        "cuda_version": null,
        "env": null,
        "system_packages": null,
        "setup_script": null,
        "base_image": null,
        "dockerfile_template": null
      },
      "python": {
        "requirements_txt": "./requirements.txt",
        "packages": null,
        "lock_packages": true,
        "pack_git_packages": true,
        "index_url": null,
        "no_index": null,
        "trusted_host": null,
        "find_links": null,
        "extra_index_url": null,
        "pip_args": null,
        "wheels": null
      },
      "conda": {
        "environment_yml": null,
        "channels": null,
        "dependencies": null,
        "pip": null
      }
    }
    ```

4. Test run API server. BentoML can start an API server from the saved model. Use
  BentoML CLI command to start an API server locally and test it with the `curl` command.

    ```bash
    bentoml serve iris_classifier:latest
    ```

    In another terminal window, make `curl` request with sample data to the API server
    and get prediction result:

    ```bash
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

    ```bash
    # jq might not be installed on your local system, please follow jq install
    # instruction at https://stedolan.github.io/jq/download/
    saved_path=$(bentoml get iris_classifier:latest -q -o json | jq -r ".uri.uri")

    # Build and push the container on your local machine.
    docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/iris-classifier" --push $saved_path
    ```

1. In `service.yaml`, replace `{username}` with your Docker hub username:

    ```yaml
    apiVersion: serving.knative.dev/v1
    kind: Service
    metadata:
      name: iris-classifier
      namespace: default
    spec:
      template:
        spec:
          containers:
            - image: docker.io/{username}/iris-classifier
              ports:
              - containerPort: 5000 # Port to route to
              livenessProbe:
                httpGet:
                  path: /healthz
                initialDelaySeconds: 3
                periodSeconds: 5
              readinessProbe:
                httpGet:
                  path: /healthz
                initialDelaySeconds: 3
                periodSeconds: 5
                failureThreshold: 3
                timeoutSeconds: 60
    ```

1. Deploy the Service to Knative Serving with `kubectl` by running the command:

    ```bash
    kubectl apply --filename service.yaml
    ```

1. Now that your service is created, Knative performs the following steps:

    - Create a new immutable revision for this version of the app.
    - Network programming to create a route, ingress, service, and load
      balance for your application.
    - Automatically scale your pods up and down (including to zero active
      pods).

1. Run the following command to find the domain URL for your service:

    ```bash
    kubectl get ksvc iris-classifier --output=custom-columns=NAME:.metadata.name,URL:.status.url

    NAME              URL
    iris-classifier   http://iris-classifer.default.example.com
    ```

1. Replace the request URL with the URL return in the previous command, and execute the
  command to get prediction result from the deployed model API endpoint.

    ```bash
    curl -v -i \
      --header "Content-Type: application/json" \
      --request POST \
      --data '[[5.1, 3.5, 1.4, 0.2]]' \
      http://iris-classifier.default.example.com/predict

    [0]
    ```

## Removing the sample app deployment

To remove the application from your cluster, delete the service record:

  ```bash
  kubectl delete --filename service.yaml
  ```
