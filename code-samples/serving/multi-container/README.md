# Knative multi-container samples

A simple web app written in Go that you can use for multi container testing.

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured.  See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
- Make sure multi-container flag is enabled as part of `config-features` configmap.

The following steps show how you can use the sample code and deploy the app to your
cluster.

You can download a working copy of the sample, by entering the
following command:

```bash
git clone -b "{{ branch }}" https://github.com/knative/docs knative-docs
```

## Using the sample code

To test multi container functionality, you must create two containers: a serving container, and a sidecar container.

The `multi-container` directory is provided in the sample code, and contains predefined code and dockerfiles for creating the containers.

You can update the default files and YAML by using the steps outlined in this section.

### Serving Container
1. After you have cloned the sample repository, navigate to the servingcontainer directory:

   `cd knative-docs/code-samples/serving/multi-container/servingcontainer`
1. Create a basic web server which listens on port 8881.
You can do this by copying the following code into the `servingcontainer.go` file:

   ```go
   package main   
   import (
   	"fmt"
   	"io"
   	"log"
   	"net/http"
   )
   func handler(w http.ResponseWriter, r *http.Request) {
   	log.Println("serving container received a request.")
   	res, err := http.Get("http://127.0.0.1:8882")
   	if err != nil {
   		log.Fatal(err)
   	}
   	resp, err := io.ReadAll(res.Body)
   	if err != nil {
   		log.Fatal(err)
   	}
   	fmt.Fprintln(w, string(resp))
   }
   func main() {
   	log.Print("serving container started...")
   	http.HandleFunc("/", handler)
   	log.Fatal(http.ListenAndServe(":8881", nil))
   }
   ```
1. Copy the following code into the `Dockerfile` file:

   ```docker
   # Use the official Golang image to create a build artifact.
   # This is based on Debian and sets the GOPATH to /go.
   # https://hub.docker.com/_/golang
   FROM golang:1.15 as builder
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
   RUN CGO_ENABLED=0 GOOS=linux go build -mod=readonly -v -o servingcontainer
   # Use the official Alpine image for a lean production container.
   # https://hub.docker.com/_/alpine
   # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
   FROM alpine:3
   RUN apk add --no-cache ca-certificates
   # Copy the binary to the production image from the builder stage.
   COPY --from=builder /app/servingcontainer /servingcontainer
   # Run the web service on container startup.
   CMD ["/servingcontainer"]
   ```

### Sidecar Container
1. After you have cloned the sample repository, navigate to the sidecarcontainer directory:
   ```text
   cd -
   cd knative-docs/code-samples/serving/multi-container/sidecarcontainer
   ```

1. Create a basic web server which listens on port 8882.
You can do this by copying the following code into the `sidecarcontainer.go` file:

   ```go
   package main
   import (
   	"fmt"
   	"log"
   	"net/http"
   )
   func handler(w http.ResponseWriter, r *http.Request) {
   	log.Println("sidecar container received a request.")
   	fmt.Fprintln(w, "Yay!! multi-container works")
   }
   func main() {
   	log.Print("sidecar container started...")
   	http.HandleFunc("/", handler)
   	log.Fatal(http.ListenAndServe(":8882", nil))
   }
   ```

1. Copy the following code into the `Dockerfile` file:

   ```docker
   # Use the official Golang image to create a build artifact.
   # This is based on Debian and sets the GOPATH to /go.
   # https://hub.docker.com/_/golang
   FROM golang:1.15 as builder
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
   RUN CGO_ENABLED=0 GOOS=linux go build -mod=readonly -v -o sidecarcontainer
   # Use the official Alpine image for a lean production container.
   # https://hub.docker.com/_/alpine
   # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
   FROM alpine:3
   RUN apk add --no-cache ca-certificates   
   # Copy the binary to the production image from the builder stage.
   COPY --from=builder /app/sidecarcontainer /sidecarcontainer   
   # Run the web service on container startup.
   CMD ["/sidecarcontainer"]
   ```

### Writing Knative Service YAML

1. After you have cloned the sample repository, navigate to the `multi-container` directory:
   1. `cd -`
   2. `cd knative-docs/code-samples/serving/multi-container/`

1. Copy the following YAML service definition into the `service.yaml` file:

   ```yaml
   apiVersion: serving.knative.dev/v1
   kind: Service
   metadata:
     name: multi-container
     namespace: default
   spec:
     template:
       spec:
         containers:
         - image: docker.io/{username}/servingcontainer
           ports:
             - containerPort: 8881
         - image: docker.io/{username}/sidecarcontainer
   ```

**NOTE:** Replace `{username}` with your Docker Hub username.

1. Use Go tool to create a
   [`go.mod`](https://github.com/golang/go/wiki/Modules#gomod) manifest:

   servingcontainer
   ```bash
   cd -
   cd knative-docs/code-samples/serving/multi-container/servingcontainer
   go mod init github.com/knative/docs/code-samples/serving/multi-container/servingcontainer
   ```
   sidecarcontainer
   ```bash
   cd -
   cd knative-docs/code-samples/serving/multi-container/sidecarcontainer
   go mod init github.com/knative/docs/code-samples/serving/multi-container/sidecarcontainer
   ```

## Building and deploying the sample

After you have modified the sample code files you can build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build the container on your local machine
   cd -
   cd knative-docs/code-samples/serving/multi-container/servingcontainer
   docker build -t {username}/servingcontainer .
   cd -
   cd knative-docs/code-samples/serving/multi-container/sidecarcontainer
   docker build -t {username}/sidecarcontainer .
   # Push the container to docker registry
   docker push {username}/servingcontainer
   docker push {username}/sidecarcontainer
   ```

1. After the build has completed and the container is pushed to Docker Hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```bash
   cd -
   cd knative-docs/code-samples/serving/multi-container
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. Run the following command to find the domain URL for your service:

   ```bash
   kubectl get ksvc multi-container  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example:

   ```bash
    NAME                URL
    multi-container       http://multi-container.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

   ```bash
   curl http://multi-container.default.1.2.3.4.sslip.io
   Yay!! multi-container works
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
