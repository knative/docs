# Hello World - Go

This guide describes the steps required to to create the `helloworld-go` sample app
and deploy it to your cluster.
The sample app reads a `TARGET` environment variable, and prints `Hello ${TARGET}!`.
If `TARGET` is not specified, `World` is used as the default value.

## Prerequisites

You will need:

- A Kubernetes cluster with Knative installed and DNS configured.  See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine, and a Docker Hub account configured.
- Optional: You can use the Knative CLI client [`kn`](https://github.com/knative/client/releases) to simplify resource creation and deployment. Alternatively, you can use `kubectl` to apply resource files directly.

## Building

Create a basic web server which listens on port 8080, by copying the following code into a new file named `helloworld.go`:

```go
package main

import (
  "fmt"
  "log"
  "net/http"
  "os"
)

func handler(w http.ResponseWriter, r *http.Request) {
  log.Print("helloworld: received a request")
  target := os.Getenv("TARGET")
  if target == "" {
    target = "World"
  }
  fmt.Fprintf(w, "Hello %s!\n", target)
}

func main() {
  log.Print("helloworld: starting server...")

  http.HandleFunc("/", handler)

  port := os.Getenv("PORT")
  if port == "" {
    port = "8080"
  }

  log.Printf("helloworld: listening on port %s", port)
  log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}
```

You can also download a working copy of the sample, by running the following commands:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-go
```


Navigate to your project directory and copy the following code into a new file named `Dockerfile`:

```dockerfile
# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
FROM golang:1.13 as builder

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies using go modules.
# Allows container builds to reuse downloaded dependencies.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
COPY . ./

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

# Run the web service on container startup.
CMD ["/server"]
```

Use the Go tool to create a [`go.mod`](https://github.com/golang/go/wiki/Modules#gomod) manifest.

```bash
go mod init github.com/knative/docs/code-samples/serving/hello-world/helloworld-go
```

## Deploying

### Build and Push the docker image

To build the sample code into a container, and push using Docker Hub, enter the following commands and replace `{username}` with your Docker Hub username:

```bash
# Build the container on your local machine
docker build -t {username}/helloworld-go .

# Push the container to docker registry
docker push {username}/helloworld-go
```

### Deploying to knative
After the build has completed and the container is pushed to docker hub, you can deploy the app into your cluster. Choose one of the following methods:

### yaml

1. Create a new file, `service.yaml` and copy the following service definition into the file. Make sure to replace `{username}` with your Docker Hub username.

 ```yaml
 apiVersion: serving.knative.dev/v1
 kind: Service
 metadata:
   name: helloworld-go
   namespace: default
 spec:
   template:
     spec:
       containers:
         - image: docker.io/{username}/helloworld-go
           env:
             - name: TARGET
               value: "Go Sample v1"
 ```

1. Check that the container image value in the `service.yaml` file matches the container you built in the previous step.

1. Apply the configuration using `kubectl`:

 ```bash
 kubectl apply --filename service.yaml
 ```
After your service is created, Knative will perform the following steps:
 - Create a new immutable revision for this version of the app.
 - Network programming to create a route, ingress, service, and load  balance for your app.
 - Automatically scale your pods up and down (including to zero active pods).

1. Run the following command to find the domain URL for your service:
 ```bash
 kubectl get ksvc helloworld-go  --output=custom-columns=NAME:.metadata.name,URL:.status.url
 ```

 Example:
 ```bash
 NAME                URL
 helloworld-go       http://helloworld-go.default.1.2.3.4.xip.io
 ```


### kn

1. Use `kn` to deploy the service:

 ```bash
 kn service create helloworld-go --image=docker.io/{username}/helloworld-go --env TARGET="Go Sample v1"
 ```

 You should see output like this:
  ```bash
  Creating service 'helloworld-go' in namespace 'default':
  0.031s The Configuration is still working to reflect the latest desired specification.
  0.051s The Route is still working to reflect the latest desired specification.
  0.076s Configuration "helloworld-go" is waiting for a Revision to become ready.
  15.694s ...
  15.738s Ingress has not yet been reconciled.
  15.784s Waiting for Envoys to receive Endpoints data.
  16.066s Waiting for load balancer to be ready
  16.237s Ready to serve.

  Service 'helloworld-go' created to latest revision 'helloworld-go-jjzgd-1' is available at URL: http://helloworld-go.default.1.2.3.4.xip.io
  ```

1. You can then access your service through the resulting URL.



## Verification

Now you can make a request to your app and see the result. Replace the following URL with the URL returned in the previous command.

```bash
curl http://helloworld-go.default.1.2.3.4.sslip.io
Hello Go Sample v1!
```

 > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing

To remove the sample app from your cluster, delete the service record:

### kubectl
```bash
kubectl delete --filename service.yaml
```

### kn
```bash
kn service delete helloworld-go
```
