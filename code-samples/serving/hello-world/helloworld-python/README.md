# Hello World - Python

This guide describes the steps required to create the `helloworld-python` sample
app and deploy it to your cluster.

The sample app reads a `TARGET` environment variable, and prints
`Hello ${TARGET}!`. If `TARGET` is not specified, `World` is used as the default
value.

You can also download a working copy of the sample, by running the following
commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-python
```

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured.
- (optional) The Knative CLI client
  [kn](https://github.com/knative/client/releases) can be used to simplify the
  deployment. Alternatively, you can use `kubectl`, and apply resource files
  directly.

## Build

1. Create a new directory and cd into it:

   ```bash
   mkdir app
   cd app
   ```

1. Create a file named `app.py` and copy the following code block into it:

   ```python
   import os

   from flask import Flask

   app = Flask(__name__)

   @app.route('/')
   def hello_world():
      target = os.environ.get('TARGET', 'World')
      return 'Hello {}!\n'.format(target)

   if __name__ == "__main__":
      app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))

   ```

1. In your project directory, create a file named `Dockerfile` and copy the following code
   block into it. See
   [official Python docker image](https://hub.docker.com/_/python/) for more
   details.

   ```docker
   # Use the official lightweight Python image.
   # https://hub.docker.com/_/python
   FROM python:3.7-slim

   # Allow statements and log messages to immediately appear in the Knative logs
   ENV PYTHONUNBUFFERED True

   # Copy local code to the container image.
   ENV APP_HOME /app
   WORKDIR $APP_HOME
   COPY . ./

   # Install production dependencies.
   RUN pip install Flask gunicorn

   # Run the web service on container startup. Here we use the gunicorn
   # webserver, with one worker process and 8 threads.
   # For environments with multiple CPU cores, increase the number of workers
   # to be equal to the cores available.
   CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
   ```

1. Create a `.dockerignore` file to ensure that any files related to a local
   build do not affect the container that you build for deployment.

   ```ignore
   Dockerfile
   README.md
   *.pyc
   *.pyo
   *.pyd
   __pycache__
   ```

  **NOTE:** Use Docker to build the sample code into a container. To build and
  push to Docker Hub or container registry of your choice, run these commands replacing `{username}` with your Docker Hub username or the URL of the container registry.

1. Use Docker to build the sample code into a container, then push the container
   to the Docker registry:

   ```bash
   # Build the container on your local machine
   docker build -t {username}/helloworld-python .

   # Push the container to docker registry
   docker push {username}/helloworld-python
   ```

## Deploying the app

1. After the build has completed and the container is pushed to Docker Hub, you
   can deploy the app into your cluster.

=== "yaml"

       1. Create a new file, `service.yaml` and copy the following service
          definition into the file. Make sure to replace `{username}` with your
          Docker Hub username or with the URL provided by your container registry

        ```yaml
          apiVersion: serving.knative.dev/v1
          kind: Service
          metadata:
            name: helloworld-python
            namespace: default
          spec:
            template:
              spec:
                containers:
                  - image: docker.io/{username}/helloworld-python
                    env:
                      - name: TARGET
                        value: "Python Sample v1"
        ```

       Ensure that the container image value in `service.yaml` matches the container
       you built in the previous step. Apply the configuration using `kubectl`:

       ```bash
       kubectl apply --filename service.yaml
       ```

=== "kn"

       With `kn` you can deploy the service with

       ```bash
       kn service create helloworld-python --image=docker.io/{username}/helloworld-python --env TARGET="Python Sample v1"
       ```

       This will wait until your service is deployed and ready, and ultimately it
       will print the URL through which you can access the service.




   During the creation of your service, Knative performs the following steps:

   - Creates a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scales your pods up and down, including scaling down to zero
     active pods.

## Verification

1. Run one of the followings commands to find the domain URL for your service.
   > Note: If your URL includes `example.com` then consult the setup instructions for
   > configuring DNS (e.g. with `sslip.io`), or [using a Custom Domain](https://knative.dev/docs/serving/using-a-custom-domain).

    === "kubectl"

        ```bash
        kubectl get ksvc helloworld-python  --output=custom-columns=NAME:.metadata.name,URL:.status.url
        ```

       ```

       Example:

       ```bash
       NAME                      URL
       helloworld-python    http://helloworld-python.default.1.2.3.4.sslip.io
       ```

=== "kn"

       ```bash
       kn service describe helloworld-python -o url
       ```

       Example:

       ```bash
       http://helloworld-python.default.1.2.3.4.sslip.io
       ```




1. Now you can make a request to your app and see the result. Replace the following URL
   with the URL returned in the previous command.

   Example:

   ```bash
   curl http://helloworld-python.default.1.2.3.4.sslip.io
   Hello Python Sample v1!

   # Even easier with kn:
   curl $(kn service describe helloworld-python -o url)
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing

To remove the sample app from your cluster, delete the service record.

=== "kubectl"

    ```bash
    kubectl delete --filename service.yaml
    ```

=== "kn"

    ```bash
    kn service delete helloworld-python
    ```
