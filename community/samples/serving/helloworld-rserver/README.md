A simple web app created with R package, [plumber](https://www.rplumber.io).
plumber creates a REST API by adding annotations to your R code. The R script
reads an environment variable `TARGET` and prints `Hello ${TARGET}!`. If the
`TARGET` environment variable is not specified, the script uses `World`.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/hello-world/helloworld-r
```

## Before you begin

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](../../../../docs/install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

1. Create a new file named `HelloWorld.R` and paste the following script:

   ```R
   #' HelloWorld function
   #' @get /
   #' @html
   function() {
     TARGET <- Sys.getenv("TARGET", "World")

     message = paste("Hello ", TARGET, "!", sep = "")
     print(message)
   }
   ```

   This file defines the endpoint `/`, using plumber annotations.

   1. Create a new file named `server.R` and paste the following code:

      ```R
      library(plumber) # https://www.rplumber.io/

      # Translate the HelloWorld file into a Plumber API
      r <- plumb("HelloWorld.R")
      # Get the PORT env var
      PORT <- strtoi(Sys.getenv("PORT", 8080))
      # Run the API
      r$run(port=PORT, host="0.0.0.0")
      ```

   1. Create a new file named `Dockerfile` and paste the following code:

      ```docker
      # The official R base image
      # https://hub.docker.com/_/r-base
      FROM r-base:3.6.0

      # Copy local code to the container image.
      WORKDIR /usr/src/app
      COPY . .

      # Install R packages
      RUN Rscript -e "install.packages('plumber', repos='http://cran.us.r-project.org/')"

      # Run the web service on container startup.
      CMD ["Rscript", "server.R"]
      ```


1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-rserver
     namespace: default
   spec:
     template:
       spec:
         containers:
         - image: docker.io/{username}/helloworld-rserver
           env:
           - name: TARGET
             value: "R Server Sample v1"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-rserver .

   # Push the container to docker registry
   docker push {username}/helloworld-rserver
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

1. Run the following command to find the domain URL for your service:

   ```shell
   kubectl get ksvc helloworld-r  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example:

   ```shell
   NAME                URL
   helloworld-r    http://helloworld-r.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-rserver.default.1.2.3.4.xip.io
   ```

   Example:

   ```shell
   curl http://helloworld-rserver.default.1.2.3.4.xip.io
   [1] "Hello R Sample v1!"
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
