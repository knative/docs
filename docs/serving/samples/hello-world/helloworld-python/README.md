A simple web app written in Python that you can use for testing. It reads in an
env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET is not
specified, it will use "World" as the TARGET.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/hello-world/helloworld-python
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

1. Create a new directory and cd into it:

   ```shell
   mkdir app
   cd app
   ```

1. Create a file named `app.py` and copy the code block below into it:

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

1. Create a file named `Dockerfile` and copy the code block below into it. See
   [official Python docker image](https://hub.docker.com/_/python/) for more
   details.

   ```docker
   # Use the official lightweight Python image.
   # https://hub.docker.com/_/python
   FROM python:3.7-slim

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

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

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

## Build and deploy this sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-python .

   # Push the container to docker registry
   docker push {username}/helloworld-python
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```shell
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-python  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-python   http://helloworld-python.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-python.default.1.2.3.4.xip.io
   Hello Python Sample v1!
   ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
