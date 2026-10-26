# Hello World - Node.js

A simple web app written in Node.js that you can use for testing. It reads in an
env variable `TARGET` and prints "Hello \${TARGET}!". If TARGET is not
specified or is empty, it will use "World" as the TARGET. The app listens on
`0.0.0.0` and uses `PORT`, defaulting to `8080` when unset or empty.

This sample uses [Node.js 24 LTS](https://github.com/nodejs/Release#release-schedule)
and [Express 5](https://expressjs.com/en/5x/api.html). The Docker image tracks
Node 24 patch updates; `package-lock.json` pins application dependencies.

Clone the working sample, then build and deploy it using the instructions below:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-nodejs
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).
Building and testing the checked-in sample requires only Docker, not a host
Node.js installation.

## Understanding the sample

Use the checked-in files from the clone rather than recreating them:

- [index.js](index.js) defines the Express `GET /` route, greeting and environment
  defaults. It binds to `0.0.0.0` so requests can reach it outside the container.
- [package.json](package.json) declares Express 5 and the start/check commands;
  [package-lock.json](package-lock.json) pins the dependency graph.
- [Dockerfile](Dockerfile) uses the Node 24 LTS image, installs production
  dependencies with `npm ci --omit=dev`, and starts Node directly.
- [service.yaml](service.yaml) defines the Knative Service and sets
  `TARGET="Node.js Sample v1"`. Replace `{username}` in its image reference with
  your Docker Hub username before deployment.

## Building and deploying the sample

From the cloned sample directory, build and deploy the sample app:

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build and push the container on your local machine.
   docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/helloworld-nodejs" --push .
   ```

1. After the build has completed and the container is pushed to docker hub, you
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

1. To find the URL for your service, use

   ```
   kubectl get ksvc helloworld-nodejs  --output=custom-columns=NAME:.metadata.name,URL:.status.url
   NAME                URL
   helloworld-nodejs   http://helloworld-nodejs.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

   ```bash
   curl http://helloworld-nodejs.default.1.2.3.4.sslip.io
   Hello Node.js Sample v1!
   ```

## Local build

From the sample directory, build and run without installing Node.js locally:

```bash
docker build -t helloworld-nodejs:local .
docker run --rm helloworld-nodejs:local npm run check
docker run --rm -p 127.0.0.1:8080:8080 -e TARGET="Node.js Sample v1" helloworld-nodejs:local
```

In another terminal, `curl http://127.0.0.1:8080` returns
`Hello Node.js Sample v1!`. Stop the container with Ctrl-C. To select a different
container port, pass `-e PORT=9090` and publish `127.0.0.1:9090:9090` instead.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
