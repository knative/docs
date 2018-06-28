# Hello World - Python sample

A simple web app written in Python that you can use for testing.
It reads in an env variable `TARGET` and prints "Hello World: ${TARGET}!". If
TARGET is not specified, it will use "NOT SPECIFIED" as the TARGET.

## Prerequisites

* A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/install/) if you need
  to create one.
* [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Steps to recreate the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. 
The following instructions recreate the source files from this folder.

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

1. Create a file named `Dockerfile` and copy the code block below into it.
   See [official Python docker image](https://hub.docker.com/_/python/) for more details.

    ```docker
    FROM python

    ENV APP_HOME /app
    COPY . $APP_HOME
    WORKDIR $APP_HOME

    RUN pip install Flask

    ENTRYPOINT ["python"]
    CMD ["app.py"]
    ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub username.

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
                image: docker.io/{username}/helloworld-python
                env:
                - name: TARGET
                  value: "Python Sample v1"
    ```

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your
   Docker Hub username:

    ```shell
    # Build the container on your local machine
    docker build -t {username}/helloworld-python .

    # Push the container to docker registry
    docker push {username}/helloworld-python
    ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in
   the previous step. Apply the configuration using `kubectl`:

    ```shell
    kubectl apply -f service.yaml
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

1. Now you can make a request to your app to see the result. Replace `{IP_ADDRESS}` 
   with the address you see returned in the previous step.

    ```shell
    curl -H "Host: helloworld-python.default.demo-domain.com" http://{IP_ADDRESS}
    Hello World: Python Sample v1!
    ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete -f service.yaml
```
