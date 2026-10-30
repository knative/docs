# Hello World - Kotlin

A simple web app written in Kotlin using [Ktor](https://ktor.io/) that you can
use for testing. It reads in an env variable `TARGET` and prints "Hello
\${TARGET}!". If TARGET is not specified, it will use "World" as the TARGET.
An empty TARGET stays empty. The server listens on `0.0.0.0` and uses `PORT`
(default `8080`). GET `/` returns an HTML greeting followed by a newline;
unknown routes return 404 and unsupported methods return 405.

The sample uses Java 21 LTS (Eclipse Temurin), Gradle 9.8.2, Kotlin 2.4.21,
and Ktor 3.6.0. Docker supplies all build tools; no host Java or Gradle install
is needed.

Clone the repository and use the checked-in sample files to build and deploy the
app:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/hello-world/helloworld-kotlin
```

## Before you begin

- A Kubernetes cluster with Knative installed and DNS configured. See
  [Install Knative Serving](https://knative.dev/docs/install/serving/install-serving-with-yaml).
- [Docker](https://www.docker.com) installed and running on your local machine,
  and a Docker Hub account configured (we'll use it for a container registry).

## Sample files

The sample files are:

- [Main.kt](src/main/kotlin/com/example/hello/Main.kt) starts the externally
  accessible Ktor server and defines the greeting route.
- [build.gradle](build.gradle) declares the Java toolchain, Kotlin/Ktor
  dependencies, application entrypoint, and lint checks.
- [Dockerfile](Dockerfile) builds the application, then runs the
  production distribution on a Java 21 JRE as a non-root user.
- [service.yaml](service.yaml) deploys the Knative Service with
  `TARGET="Kotlin Sample v1"`. Before deploying, replace `{username}` in its image
  reference with your Docker Hub username.

## Build and deploy this sample

From the cloned sample directory, build and deploy the app using the checked-in
files. The Docker build runs `ktlintCheck` before
assembling the production distribution.

For a local build and smoke test without publishing to a registry:

```bash
docker build -t helloworld-kotlin:local .
docker run --rm -p 127.0.0.1:8080:8080 helloworld-kotlin:local
# In another terminal:
curl --fail http://127.0.0.1:8080/
# Hello World!
```

To use a custom target and port, run instead:

```bash
docker run --rm -e TARGET='Kotlin Sample v1' -e PORT=8081 \
  -p 127.0.0.1:8081:8081 helloworld-kotlin:local
```

When deploying a custom port to Knative, set the container's `ports.containerPort`
(e.g. `8081`) in `service.yaml`; Knative injects `PORT` automatically. Do not use
Knative-reserved ports such as 9090 or 9091.

1. Use Docker to build the sample code into a container. To build and push with
   Docker Hub, run these commands replacing `{username}` with your Docker Hub
   username:

   ```bash
   # Build and push the container on your local machine.
   docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/helloworld-kotlin" --push .
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

   ```bash
   kubectl get ksvc helloworld-kotlin  --output=custom-columns=NAME:.metadata.name,URL:.status.url

   NAME                URL
   helloworld-kotlin   http://helloworld-kotlin.default.1.2.3.4.sslip.io
   ```

1. Now you can make a request to your app and see the result. Replace
   the following URL with the URL returned in the previous command.

   ```bash
   curl http://helloworld-kotlin.default.1.2.3.4.sslip.io
   Hello Kotlin Sample v1!
   ```

## Remove the sample app deployment

To remove the sample app from your cluster, delete the service record:

```bash
kubectl delete --filename service.yaml
```
