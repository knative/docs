---
title: "Hello World - R"
linkTitle: "R"
weight: 1
type: "docs"
---

A simple web app that executes an R script. The R script reads an env
variable `TARGET` and prints `Hello ${TARGET}!`. If the `TARGET` environment
variable is not specified, the script uses `World`.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/hello-world/helloworld-r
```

## Before you begin

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../../install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

1. Create a new file named `HelloWorld.R` and paste the following script:

   ```R
   #!/usr/bin/Rscript
   TARGET <- Sys.getenv("TARGET", "World")

   message = paste("Hello ", TARGET, "!", sep = "")
   print(message)
   ```

1. Create a new file named `app.py` and paste the following code. We use a
   basic web server written in Python to execute the R script:

   ```py
   import os
   import subprocess

   from flask import Flask

   app = Flask(__name__)

   @app.route('/')
   def hello_world():
       try:
           output = subprocess.check_output('/usr/bin/Rscript HelloWorld.R', shell=True)
           print(output)
       except subprocess.CalledProcessError:
           return "Error in R script.", 500

       return output


   if __name__ == "__main__":
       app.run(debug=True,host='0.0.0.0',port=int(os.environ.get('PORT', 8080)))
   ```

1. Create a new file named `Dockerfile` and copy the code block below into it.

   ```docker
   # Use the official Python image.
   # https://hub.docker.com/_/python
   FROM python:3.7

   # Copy local code to the container image.
   ENV APP_HOME /app
   WORKDIR $APP_HOME
   COPY . .

   # Install production dependencies.
   RUN pip install Flask gunicorn

   # Install R
   RUN apt-get update && \
       apt-get install -y r-base

   # Run the web service on container startup. Here we use the gunicorn
   # webserver, with one worker process and 8 threads.
   # For environments with multiple CPU cores, increase the number of workers
   # to be equal to the cores available.
   CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 app:app
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
   kind: Service
   metadata:
     name: helloworld-r
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-r
             env:
               - name: TARGET
                 value: "R Sample v1"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-r .

   # Push the container to docker registry
   docker push {username}/helloworld-r
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```shell
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative performs the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. Run the following command to find the external IP address for your service.
   The ingress IP for your cluster is returned. If you just created your
   cluster, you might need to wait and rerun the command until your service gets
   asssigned an external IP address.

   ```shell
   kubectl get svc knative-ingressgateway --namespace istio-system
   ```

   Example:

   ```shell
   NAME                     TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                      AGE
   knative-ingressgateway   LoadBalancer   10.23.247.74   35.203.155.229   80:32380/TCP,443:32390/TCP,32400:32400/TCP   2d

   ```

1. Run the following command to find the domain URL for your service:

   ```shell
   kubectl get ksvc helloworld-r  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example:

   ```shell
   NAME                URL
   helloworld-r    http://helloworld-r.default.example.com
   ```

1. Test your app by sending it a request. Use the following `curl` command with
   the domain URL `helloworld-r.default.example.com` and `EXTERNAL-IP`
   address that you retrieved in the previous steps:

   ```shell
   curl -H "Host: helloworld-r.default.example.com" http://{EXTERNAL_IP_ADDRESS}
   ```

   Example:

   ```shell
   curl -H "Host: helloworld-r.default.example.com" http://35.203.155.229
   [1] "Hello R Sample v1!"
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
