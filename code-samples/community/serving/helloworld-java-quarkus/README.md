# Hello World — Java (Quarkus)

A small [Quarkus REST](https://quarkus.io/guides/rest) application for Knative
Serving, using **Quarkus 3.40.1.1 LTS**, **Eclipse Temurin Java 25 LTS** and
**Maven 3.9.16**. Docker builds the application; no local JDK or Maven
installation is required.

GET `/` returns HTTP 200 and `text/plain` with exactly `Hello ${TARGET}!`.
`TARGET` defaults to `World` (also when empty). The server binds to `0.0.0.0`;
`PORT` defaults to 8080 (including an empty value in the container). HEAD `/`
returns 200 and POST `/` returns 405.

## Prerequisites

- Docker (Linux arm64 and amd64 are supported by the selected toolchain images).
- For deployment: a Kubernetes cluster with [Knative Serving and an ingress
  provider installed](https://knative.dev/docs/install/), and `kubectl`.
- A container registry accessible to your cluster. Registry publication requires
  your own account; it is unnecessary for local testing.

## Get the sample

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/community/serving/helloworld-java-quarkus
```

## Source and configuration

Use the checked-in [GreetingResource.java](src/main/java/com/redhat/developer/demos/GreetingResource.java),
which uses Jakarta REST APIs and MicroProfile Config to return the greeting.
Its optional `target` configuration treats both missing and empty values as
`World`. The checked-in [application.properties](src/main/resources/application.properties)
sets the external binding and configurable port.

The [pom.xml](pom.xml) imports `io.quarkus.platform:quarkus-bom:3.40.1.1` and uses
`quarkus-rest`. The build runs Java compiler lint and Quarkus fast-jar packaging.

## Build with Docker

From the sample directory:

```bash
# Compile and package in the build stage.
docker build --target build -t helloworld-java-quarkus-build .

# Build the actual production image.
docker build -t helloworld-java-quarkus .
```

The multistage [Dockerfile](Dockerfile) uses Maven/Temurin 25 for compilation and a
Temurin 25 JRE for runtime. It copies the **entire** `target/quarkus-app/`
fast-jar directory and runs as non-root UID 1001.

Run locally in one terminal:

```bash
docker run --rm -p 8080:8080 helloworld-java-quarkus
```

Then, in another terminal:

```bash
curl -fsS http://localhost:8080/
# Hello World!
```

To exercise custom configuration, stop the first container and run:

```bash
docker run --rm -p 9090:9090 -e PORT=9090 -e 'TARGET=Quarkus Sample v1' \
  helloworld-java-quarkus
```

```bash
curl -fsS http://localhost:9090/
# Hello Quarkus Sample v1!
```

### Optional local development

With a supported Java 25 JDK and Maven 3.9.16 installed (or use the Docker
build above without a local toolchain):

```bash
mvn clean verify
mvn quarkus:dev
```

## Publish and deploy

Replace `{username}` below and in [service.yaml](service.yaml) with your registry namespace.
For an arm64 cluster use `linux/arm64`; for an amd64 cluster use `linux/amd64`.
To publish both architectures using a configured buildx builder:

```bash
docker buildx build --platform linux/arm64,linux/amd64 \
  -t '{username}/helloworld-java-quarkus' --push .
```

The checked-in [Service manifest](service.yaml) uses the image you publish and sets
`TARGET=Quarkus Sample v1`. It routes to container port 8080. Knative injects
`PORT` from `containerPort`; do not set the reserved `PORT` environment variable
in a Knative Service. To test a different port there, set `containerPort` to an
unreserved value such as 8088 (9090 is reserved by Knative). The explicit
`PORT=9090` Docker command above is for standalone local testing only.

```bash
kubectl apply -f service.yaml
kubectl wait --for=condition=Ready ksvc/helloworld-java-quarkus --timeout=180s
kubectl get ksvc helloworld-java-quarkus
```

Request the URL returned by Knative:

```bash
URL=$(kubectl get ksvc helloworld-java-quarkus -o jsonpath='{.status.url}')
curl -fsS "$URL"
# Hello Quarkus Sample v1!
```

For an isolated kind cluster, publishing can be avoided by tagging the local
image `dev.local/helloworld-java-quarkus:local`, loading it into the node with
`kind load docker-image`, and adapting the Service image reference with
`imagePullPolicy: IfNotPresent`. Use your own namespace and the ingress setup
of that cluster; do not reuse a remote maintainer's image as a substitute.

## Remove the deployment

```bash
kubectl delete -f service.yaml
```
