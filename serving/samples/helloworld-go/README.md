# Hello World - Go sample

A simple web app written in Go that you can use for testing. It reads in an env
variable `TARGET` and prints `Hello ${TARGET}!`. If `TARGET` is not specified,
it will use `World` as the `TARGET`.

## Prerequisites

- A Kubernetes cluster with Knative installed. Follow the
  [installation instructions](https://github.com/knative/docs/blob/master/install/README.md)
  if you need to create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Recreating the sample code

While you can clone all of the code from this directory, hello world apps are
generally more useful if you build them step-by-step. The following instructions
recreate the source files from this folder.

1. Create a new file named `helloworld.go` and paste the following code. This
   code creates a basic web server which listens on port 8080:

   ```go
   package main

   import (
     "fmt"
     "log"
     "net/http"
     "os"
   )

   func handler(w http.ResponseWriter, r *http.Request) {
     log.Print("Hello world received a request.")
     target := os.Getenv("TARGET")
     if target == "" {
       target = "World"
     }
     fmt.Fprintf(w, "Hello %s!\n", target)
   }

   func main() {
     log.Print("Hello world sample started.")

     http.HandleFunc("/", handler)

     port := os.Getenv("PORT")
     if port == "" {
       port = "8080"
     }

     log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
   }
   ```

1. In your project directory, create a file named `Dockerfile` and copy the code
   block below into it. For detailed instructions on dockerizing a Go app, see
   [Deploying Go servers with Docker](https://blog.golang.org/docker).

   ```docker
   # Use the offical Golang image to create a build artifact.
   # This is based on Debian and sets the GOPATH to /go.
   # https://hub.docker.com/_/golang
   FROM golang as builder

   # Copy local code to the container image.
   WORKDIR /go/src/github.com/knative/docs/helloworld
   COPY . .

   # Build the helloworld command inside the container.
   # (You may fetch or manage dependencies here,
   # either manually or with a tool like "godep".)
   RUN CGO_ENABLED=0 GOOS=linux go build -v -o helloworld

   # Use a Docker multi-stage build to create a lean production image.
   # https://docs.docker.com/develop/develop-images/multistage-build/#use-multi-stage-builds
   FROM alpine

   # Copy the binary to the production image from the builder stage.
   COPY --from=builder /go/src/github.com/knative/docs/helloworld/helloworld /helloworld

   # Configure and document the service HTTP port.
   ENV PORT 8080
   EXPOSE $PORT

   # Run the web service on container startup.
   CMD ["/helloworld"]
   ```

1. Create a new file, `service.yaml` and copy the following service definition
   into the file. Make sure to replace `{username}` with your Docker Hub
   username.

   ```yaml
   apiVersion: serving.knative.dev/v1alpha1
   kind: Service
   metadata:
     name: helloworld-go
     namespace: default
   spec:
     runLatest:
       configuration:
         revisionTemplate:
           spec:
             container:
               image: docker.io/{username}/helloworld-go
               env:
                 - name: TARGET
                   value: "Go Sample v1"
   ```

## Building and deploying the sample

Once you have recreated the sample code files (or used the files in the sample
folder) you're ready to build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```shell
   # Build the container on your local machine
   docker build -t {username}/helloworld-go .

   # Push the container to docker registry
   docker push {username}/helloworld-go
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
   kubectl get ksvc helloworld-go  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
   ```

   Example:

   ```shell
   NAME                DOMAIN
   helloworld-go       helloworld-go.default.example.com
   ```

1. Test your app by sending it a request. Use the following `curl` command with
   the domain URL `helloworld-go.default.example.com` and `EXTERNAL-IP` address
   that you retrieved in the previous steps:

   ```shell
   curl -H "Host: helloworld-go.default.example.com" http://{EXTERNAL_IP_ADDRESS}
   ```

   Example:

   ```shell
   curl -H "Host: helloworld-go.default.example.com" http://35.203.155.229
   Hello World: Go Sample v1!
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```shell
kubectl delete --filename service.yaml
```
