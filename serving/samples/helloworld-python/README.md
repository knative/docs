# Hello World - Python sample

This sample application shows how to create a hello world application in Python 3.
When called, this application reads an env variable 'TARGET' 
and prints "Hello World: ${TARGET}!".
If TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* You have a Kubernetes cluster with Knative installed. Follow the [installation instructions](https://github.com/knative/install/) if you need to do this. 
* You have installed and initialized [Google Cloud SDK](https://cloud.google.com/sdk/docs/) and have created a project in Google Cloud.
* You have `kubectl` configured to connect to the Kubernetes cluster running Knative.
* You have installed [Python 3](https://www.python.org/downloads/).

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world apps are generally more useful if you build them step-by-step. The following instructions recreate the source files from this folder.

1. Create a new directory and cd into it:
    ````shell
    mkdir app
    cd app
    ````
1. Create a file named `app.py` and copy the code block below into it:

    ```python
    import os

    from flask import Flask

    app = Flask(__name__)

    @app.route('/')
    def hello_world():
        target = os.environ.get('TARGET', 'NOT SPECIFIED')
        return 'Hello World: {}!\n'.format(target)

    if __name__ == "__main__":
        app.run(debug=True,host='0.0.0.0',port=8080)
    ```

1. Create a file named `Dockerfile` and copy the code block below into it. See [official Python docker image](https://hub.docker.com/_/python/) for more details.

    ```docker
    FROM python:3

    ENV APP_HOME /app
    COPY . $APP_HOME
    WORKDIR $APP_HOME

    RUN pip install Flask

    ENTRYPOINT ["python"]
    CMD ["app.py"]
    ```

1. Create a file named `app.yaml` and copy the following service definition into the file. Make sure to replace `{PROJECT_ID}` with the ID of your Google Cloud project. If you are using docker or another container registry instead, replace the entire image path.

    ```yaml
    apiVersion: serving.knative.dev/v1alpha1
    kind: Service
    metadata:
      name: helloworld-python
      namespace: default
    spec:
      runLatest:
        configuration:
          revisionTemplate:
            spec:
              container:
                image: gcr.io/{PROJECT_ID}/helloworld-python
                env:
                - name: TARGET
                  value: "Python Sample v1"
    ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample folder) you're ready to build and deploy the sample app.

1. For this example, we'll use Google Cloud Container Builder to build the sample into a container. To use container builder, execute the following gcloud command. Make sure to replace `${PROJECT_ID}` with the ID of your Google Cloud project.

    ```shell
    gcloud container builds submit --tag gcr.io/${PROJECT_ID}/helloworld-python
    ```

1. After the build has completed, you can deploy the app into your cluster. Ensure that the container image value in `app.yaml` matches the container you build in the previous step. Apply the configuration using kubectl:

    ```shell
    kubectl apply -f app.yaml
    ```

1. Now that your service is created, Knative will perform the following steps:
   * Create a new immutable revision for this version of the app.
   * Network programming to create a route, ingress, service, and load balance for your app.
   * Automatically scale your pods up and down (including to zero active pods).

1. To find the URL and IP address for your service, use kubectl to list the ingress points in the cluster:

    ```shell
    kubectl get ing

    NAME                        HOSTS                                                                                   ADDRESS        PORTS     AGE
    helloworld-python-ingress   helloworld-python.default.demo-domain.com,*.helloworld-python.default.demo-domain.com   35.232.134.1   80        1m
    ```

1. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}` with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-python.default.demo-domain.com" http://{IP_ADDRESS}
    Hello World: Python Sample v1!
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f app.yaml
```
