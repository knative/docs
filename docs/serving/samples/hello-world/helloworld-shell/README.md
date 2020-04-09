A simple web app that executes a shell script. The shell script reads an env
variable `TARGET` and prints `Hello ${TARGET}!`. If the `TARGET` environment
variable is not specified, the script uses `World`.

Follow the steps below to create the sample code and then deploy the app to your
cluster. You can also download a working copy of the sample, by running the
following commands:

```shell
git clone -b "{{< branch >}}" https://github.com/knative/docs knative-docs
cd knative-docs/docs/serving/samples/hello-world/helloworld-shell
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [installation instructions](../../../../install/README.md) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

1. Create a new file named `script.sh` and paste the following script:

   ```sh
   #!/bin/sh
   echo Hello ${TARGET:=World}!
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
     log.Print("helloworld: received a request")

     cmd := exec.CommandContext(r.Context(), "/bin/sh", "script.sh")
     cmd.Stderr = os.Stderr
     out, err := cmd.Output()
     if err != nil {
       w.WriteHeader(500)
     }
     w.Write(out)
   }

   func main() {
     log.Print("helloworld: starting server...")

     http.HandleFunc("/", handler)

     port := os.Getenv("PORT")
     if port == "" {
       port = "8080"
     }

     log.Printf("helloworld: listening on %s", port)
     log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
   }
   ```

1. Create a new file named `Dockerfile` and copy the code block below into it.

   ```docker
   # Use the official Golang image to create a build artifact.
   # This is based on Debian and sets the GOPATH to /go.
   # https://hub.docker.com/_/golang
   FROM golang:1.13 as builder

   # Create and change to the app directory.
   WORKDIR /app

   # Retrieve application dependencies using go modules.
   # Allows container builds to reuse downloaded dependencies.
   COPY go.* ./
   RUN go mod download

   # Copy local code to the container image.
   COPY invoke.go ./

   # Build the binary.
   # -mod=readonly ensures immutable go.mod and go.sum in container builds.
   RUN CGO_ENABLED=0 GOOS=linux go build -mod=readonly -v -o server

   # Use the official Alpine image for a lean production container.
   # https://hub.docker.com/_/alpine
   # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
   FROM alpine:3
   RUN apk add --no-cache ca-certificates

   # Copy the binary to the production image from the builder stage.
   COPY --from=builder /app/server /server
   COPY script.sh ./

   # Run the web service on container startup.
   CMD ["/server"]
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: helloworld-shell
     namespace: default
   spec:
     template:
       spec:
         containers:
           - image: docker.io/{username}/helloworld-shell
             env:
               - name: TARGET
                 value: "Shell Sample v1"
   ```

1. Use the go tool to create a
   [`go.mod`](https://github.com/golang/go/wiki/Modules#gomod) manifest.

   ```shell
   go mod init github.com/knative/docs/docs/serving/samples/hello-world/helloworld-shell
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-shell .

   # Push the container to docker registry
   docker push {username}/helloworld-shell
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
   kubectl get ksvc helloworld-shell  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example:

   ```shell
   NAME                URL
   helloworld-shell    http://helloworld-shell.default.1.2.3.4.xip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```shell
   curl http://helloworld-shell.default.1.2.3.4.xip.io
   ```

   Example:

   ```shell
   curl http://helloworld-shell.default.1.2.3.4.xip.io
   Hello Shell Sample v1!
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
