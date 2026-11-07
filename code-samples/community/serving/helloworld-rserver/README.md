# Hello World - R server

A simple web app created with R package, [plumber](https://www.rplumber.io).
plumber creates a REST API by adding annotations to your R code. The R script
reads an environment variable `TARGET` and returns `Hello ${TARGET}!` as HTML.
If `TARGET` is not specified, the script uses `World`; an explicitly empty value
produces `Hello !`. `PORT` defaults to `8080` and must be an integer from 1 to
65535; invalid or empty values fail startup.

The Dockerfile uses R 4.6.1 and installs plumber from CRAN.

Clone the sample, then follow the steps below to test
and deploy the app to your cluster:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/community/serving/helloworld-rserver
```

## Before you begin

- A Kubernetes cluster with Knative installed. Follow the
  [Knative installation instructions](https://knative.dev/docs/install/) if you need to
  create one.
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Understanding the sample files

Use the files from the cloned directory rather than recreating copies:

- [`HelloWorld.R`](HelloWorld.R) defines `GET /` using plumber annotations and
  returns the greeting with the HTML serializer.
- [`server.R`](server.R) validates `PORT`, loads the API, and listens on
  `0.0.0.0` so Docker and Knative can reach it.
- [`Dockerfile`](Dockerfile) installs plumber with `install.packages("plumber", repos="https://cloud.r-project.org")`
  and starts the server.
- [`service.yaml`](service.yaml) is the Knative Service manifest. Replace
  `{username}` in its image reference with your Docker Hub username before
  deploying; its `TARGET` setting produces `Hello R Server Sample v1!`.

## Testing locally

Build the image and exercise the actual HTTP listener with Docker:

```bash
docker build -t helloworld-rserver .
docker run --rm -p 127.0.0.1:8080:8080 helloworld-rserver
# In another terminal: curl -i http://127.0.0.1:8080/
# Expected: HTTP 200, text/html; charset=UTF-8, body Hello World!
```

Stop the container before testing an override:

```bash
docker run --rm -p 127.0.0.1:9090:9090 -e PORT=9090 -e TARGET='R Server Sample v1' helloworld-rserver
# In another terminal: curl -i http://127.0.0.1:9090/
# Expected body: Hello R Server Sample v1!
```

An unknown path returns HTTP 404; unsupported methods such as `POST /` return
HTTP 405. Stop the local container when finished. For a custom port on Knative,
set `containers[].ports[].containerPort` to an allowed port (for example, `18081`);
Knative injects the matching `PORT`. Port `9090` in the standalone Docker example
is reserved by Knative and cannot be used as a Knative container port.

## Building and deploying the sample

From the cloned sample directory, build and deploy the sample app.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build and push the container on your local machine.
   docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/helloworld-rserver" --push .
   ```

1. After the build has completed and the container is pushed to docker hub, you
   can deploy the app into your cluster. Ensure that the container image value
   in `service.yaml` matches the container you built in the previous step. Apply
   the configuration using `kubectl`:

   ```bash
   kubectl apply --filename service.yaml
   ```

1. Now that your service is created, Knative performs the following steps:

   - Create a new immutable revision for this version of the app.
   - Network programming to create a route, ingress, service, and load balance
     for your app.
   - Automatically scale your pods up and down (including to zero active pods).

1. Run the following command to find the domain URL for your service:

   ```bash
   kubectl get ksvc helloworld-rserver --output=custom-columns=NAME:.metadata.name,URL:.status.url
   ```

   Example:

   ```bash
   NAME                 URL
   helloworld-rserver   http://helloworld-rserver.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the URL below with the URL returned in the previous command.

   ```bash
   curl http://helloworld-rserver.default.1.2.3.4.sslip.io
   ```

   Example:

   ```bash
   curl http://helloworld-rserver.default.1.2.3.4.sslip.io
   Hello R Server Sample v1!
   ```

   > Note: Add `-v` option to get more detail if the `curl` command failed.

## Removing the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
