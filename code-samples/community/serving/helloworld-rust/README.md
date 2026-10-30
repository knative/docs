# Hello World - Rust

A simple web app written in Rust that you can use for testing. It reads in an
env variable `TARGET` and responds with "Hello ${TARGET}!". If `TARGET` is not
specified, it will use "World" as the target. It listens on `PORT` (default 8080);
an invalid port value falls back to 8080.

## Prerequisites

- A Kubernetes cluster with Knative installed and DNS configured. Follow the
  [Knative installation instructions](https://knative.dev/docs/install/) if you need to create
  one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Get and explore the sample code

Clone this repository and change to the sample directory:

```bash
git clone https://github.com/knative/docs.git
cd docs/code-samples/community/serving/helloworld-rust
```

Use the checked-in files rather than recreating copies from this guide:

- [Cargo.toml](Cargo.toml) declares the Rust package and its dependencies.
- [Cargo.lock](Cargo.lock) selects the dependency versions compatible with the
  Rust toolchain in the Dockerfile. Keep it with the source when building.
- [src/main.rs](src/main.rs) implements the Hyper server. It binds to all
  interfaces, reads `PORT`, and responds to requests with the configured greeting.
- [Dockerfile](Dockerfile) builds and installs the release binary with
  `cargo install --locked --path .`, then runs `hellorust` on startup.
- [service.yaml](service.yaml) defines the Knative Service and sets
  `TARGET=Rust Sample v1`. Replace `{username}` in its image reference with your
  Docker Hub username before deploying.

## Build and deploy this sample

From the sample directory, build and deploy the sample app:

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, enter these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build and push the container on your local machine.
   docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/helloworld-rust" --push .
   ```

1. After the build has completed and the container is pushed to Docker Hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```bash
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative will perform the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. To find the URL for your service, enter:

   ```bash
   kubectl get ksvc helloworld-rust  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-rust     http://helloworld-rust.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```bash
   curl http://helloworld-rust.default.1.2.3.4.sslip.io
   Hello Rust Sample v1!
   ```

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
