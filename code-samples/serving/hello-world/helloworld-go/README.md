# Hello World - Go

This guide describes the steps required to create the `helloworld-go` sample app
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

The web server in [`helloworld.go`](helloworld.go) listens on all interfaces on
port 8080 by default. Set `PORT` to use a different port. Each request returns the
greeting with a trailing newline; an unset or empty `TARGET` defaults to `World`.

Clone the repository to use the checked-in source, build recipe and service manifest:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-go
```


The checked-in [`Dockerfile`](Dockerfile) compiles a static Go binary and copies
it into a small Alpine runtime image with CA certificates. The module manifest
[`go.mod`](go.mod) is already included; do not run `go mod init` in the cloned sample.

## Testing

## Deploying

### Build and Push the docker image

To build the sample code into a container, and push using Docker Hub, enter the following commands and replace `{username}` with your Docker Hub username:

```bash
# Refresh base images, build and push the container on your local machine.
docker buildx build --pull --platform linux/arm64,linux/amd64 -t "{username}/helloworld-go" --push .
```

### Deploying to knative
After the build has completed and the container is pushed to docker hub, you can deploy the app into your cluster. Choose one of the following methods:

### yaml

1. Open the checked-in [`service.yaml`](service.yaml) and replace `{username}`
   with your Docker Hub username. It creates a Knative Service in the `default`
   namespace with `TARGET="Go Sample v1"`.

1. Check that the image in `service.yaml` matches the image you built and pushed.

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
 helloworld-go       http://helloworld-go.default.1.2.3.4.sslip.io
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

  Service 'helloworld-go' created to latest revision 'helloworld-go-jjzgd-1' is available at URL: http://helloworld-go.default.1.2.3.4.sslip.io
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
