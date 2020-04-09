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
  [installation instructions](../../../../docs/install/README.md) if you need to
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

   1. Create a new file named `invoke.go` and paste the following code. We use a
      basic web server written in Go to execute the shell script:

      ```go
      package main

      import (
         "fmt"
         "log"
         "net/http"
         "os"
         "os/exec"
      )

      func handler(w http.ResponseWriter, r *http.Request) {
         cmd := exec.CommandContext(r.Context(), "Rscript", "HelloWorld.R")
         cmd.Stderr = os.Stderr
         out, err := cmd.Output()
         if err != nil {
             w.WriteHeader(500)
         }
         w.Write(out)
      }

      func main() {
         http.HandleFunc("/", handler)

         port := os.Getenv("PORT")
         if port == "" {
             port = "8080"
         }

         log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
      }
      ```

   1. Create a new file named `Dockerfile` and copy the code block below into it.

      ```docker
      # Use the offical Golang image to create a build artifact.
      # This is based on Debian and sets the GOPATH to /go.
      # https://hub.docker.com/_/golang
      FROM golang:1.12 as builder

      # Copy local code to the container image.
      WORKDIR /go/src/github.com/knative/docs/helloworld-r
      COPY invoke.go .

      # Build the command inside the container.
      # (You may fetch or manage dependencies here,
      # either manually or with a tool like "godep".)
      RUN CGO_ENABLED=0 GOOS=linux go build -v -o invoke

      # The official R base image
      # https://hub.docker.com/_/r-base
      # Use a Docker multi-stage build to create a lean production image.
      # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
      FROM r-base:3.6.0

      # Copy Go binary
      COPY --from=builder /go/src/github.com/knative/docs/helloworld-r/invoke /invoke
      COPY HelloWorld.R .

      # Run the web service on container startup.
      CMD ["/invoke"]
      ```


1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
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

1. Run the following command to find the domain URL for your service:

   ```shell
   kubectl get ksvc helloworld-r  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example:

   ```shell
   NAME                URL
   helloworld-r        http://helloworld-r.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-r.default.1.2.3.4.xip.io
   ```

   Example:

   ```shell
   curl http://helloworld-r.default.1.2.3.4.xip.io
   [1] "Hello R Sample v1!"
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
