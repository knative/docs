# Knative Install using Gloo on a Kubernetes Cluster

This guide walks you through the installation of the latest version of Knative
using pre-built images.

## Before you begin

Knative requires a Kubernetes cluster v1.11 or newer with the
[MutatingAdmissionWebhook admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#how-do-i-turn-on-an-admission-controller)
enabled. `kubectl` v1.10 is also required. This guide assumes that you've
already created a Kubernetes cluster which you're comfortable installing _alpha_
software on.

This guide assumes you are using bash in a Mac or Linux environment; some
commands will need to be adjusted for use in a Windows environment.

## Installing Glooctl

This installation method for Knative depends on Gloo. Run the following to
install `glooctl`, the Gloo command line.

```shell
curl -sL https://run.solo.io/gloo/install | sh
```

Alternatively, you can download the Gloo CLI directly via
[the github releases](https://github.com/solo-io/gloo/releases) page.

Next, add `glooctl` to your path with:

```shell
export PATH=$HOME/.gloo/bin:$PATH
```

Verify the CLI is installed and running correctly with:

```shell
glooctl --version
```

### Installing Gloo and Knative to your cluster

Finally, install Gloo and Knative in a single command with `glooctl`:

```shell
glooctl install knative
```

> Note: To see the content of the kubernetes manifest glooctl installs, run
> `glooctl install knative --dry-run`. Monitor the Gloo components until all of
> the components show a `STATUS` of `Running` or `Completed`:

```shell
kubectl get pods --namespace gloo-system
kubectl get pods --namespace knative-serving
```

It will take a few minutes for all the components to be up and running; you can
rerun the command to see the current status.

> Note: Instead of rerunning the command, you can add `--watch` to the above
> commands to view the component's status updates in real time. Use CTRL+C to
> exit watch mode.

Now you can deploy an app using your freshly installed Knative environment.

## Deploying an app

Now that your cluster has Knative installed, you can see what Knative has to
offer.

To deploy your first app with Knative, follow the step-by-step
[Getting Started with Knative App Deployment](getting-started-knative-app.md)
guide.

Note that when you've finished deploying the app, you'll need to connect to the
Gloo Gateway rather than the Istio Gateway.

To get the URL of the Gloo Gateway, run

```bash
export GATEWAY_URL=$(glooctl proxy url --name clusteringress-proxy)

echo $GATEWAY_URL
http://192.168.99.230:31864
```

To send requests to your service:

```bash
export GATEWAY_URL=$(glooctl proxy url --name clusteringress-proxy)

curl -H "Host: helloworld-go.myproject.example.com" $GATEWAY_URL
```

The full instructions for the
[Go Hello-World Sample](../serving/samples/helloworld-go) with this substitution
are published bellow:

### Deploy the Hello-World Go App:

Create a new file named `helloworld.go` and paste the following code. This code
creates a basic web server which listens on port 8080:

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

In your project directory, create a file named `Dockerfile` and copy the code
block below into it. For detailed instructions on dockerizing a Go app, see
[Deploying Go servers with Docker](https://blog.golang.org/docker).

```dockerfile
# Use the official Golang image to create a build artifact.
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

# Service must listen to $PORT environment variable.
# This default value facilitates local development.
ENV PORT 8080

# Run the web service on container startup.
CMD ["/helloworld"]
```

Create a new file, `service.yaml` and copy the following service definition into
the file. Make sure to replace `{username}` with your Docker Hub username.

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

Once the sample code has been created, we'll build and deploy it

Use Docker to build the sample code into a container. To build and push with
Docker Hub, run these commands replacing `{username}` with your Docker Hub
username:

```bash
# Build the container on your local machine
docker build -t {username}/helloworld-go .

# Push the container to docker registry
docker push {username}/helloworld-go
```

After the build has completed and the container is pushed to docker hub, you can
deploy the app into your cluster. Ensure that the container image value in
`service.yaml` matches the container you built in the previous step. Apply the
configuration using `kubectl`:

```bash
kubectl apply --filename service.yaml
```

Now that your service is created, Knative will perform the following steps:

- Create a new immutable revision for this version of the app.
- Network programming to create a route, ingress, service, and load balance for
  your app.
- Automatically scale your pods up and down (including to zero active pods).

- Run the following command to find the external IP address for the Gloo cluster
  ingress.

```bash
CLUSTERINGRESS_URL=$(glooctl proxy url --name clusteringress-proxy)
echo $CLUSTERINGRESS_URL
http://192.168.99.230:31864
```

Run the following command to find the domain URL for your service:

```bash
kubectl get ksvc helloworld-go -n default  --output=custom-columns=NAME:.metadata.name,DOMAIN:.status.domain
```

Example:

```bash
NAME                DOMAIN
helloworld-go       helloworld-go.default.example.com
```

Test your app by sending it a request. Use the following `curl` command with the
domain URL `helloworld-go.default.example.com` and `EXTERNAL-IP` address that
you retrieved in the previous steps:

```bash
curl -H "Host: helloworld-go.default.example.com" ${CLUSTERINGRESS_URL}
Hello Go Sample v1!
```

> Note: Add `-v` option to get more detail if the `curl` command failed.

Removing the sample app deployment  
To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```

Great! our Knative ingress is up and running. See
https://github.com/knative/docs for more information on using Knative.
