# Hello World — Eclipse Vert.x

Deploy a minimal Java HTTP application to Knative Serving using Eclipse Vert.x
5.2.2 and Eclipse Temurin Java 21 LTS. Docker supplies Maven 3.9.16, the JDK, and
all dependencies; no host Java, Maven, or Vert.x installation is required.

## Application behavior

- `TARGET` defaults to `NOT SPECIFIED` when unset. An explicitly empty value stays
  empty.
- `PORT` defaults to `8080`; Knative supplies it automatically. A custom port must
  be an integer from 1 to 65535. Invalid or empty values fail at startup.
- Requests on any path return HTTP 200 and `Content-Type: text/plain`. The exact
  body is `Hello World: ${TARGET}`, without an exclamation mark or trailing
  newline. HTTP/1.1 GET and POST responses are chunked; HEAD has no body.

The [Java source](src/main/java/com/example/helloworld/HelloWorld.java) uses the
Vert.x core asynchronous HTTP API directly. The [POM](pom.xml) builds an
executable shaded JAR. The
[Dockerfile](Dockerfile) builds in a JDK stage, then copies only the
application JAR into a public Temurin JRE image.

## Prerequisites

- Docker for building and running the container.
- curl for HTTP checks.
- For cluster deployment: a working Kubernetes cluster with
  [Knative Serving installed](https://knative.dev/docs/install/), kubectl, and
  permission to push an image to a registry your cluster can access.

Clone the [Knative docs repository](https://github.com/knative/docs), then run all
commands below from `code-samples/community/serving/helloworld-vertx`.

## Build and run locally

Build the final image:

```bash
docker build -t helloworld-vertx:local .
```

Start the image with default settings:

```bash
docker run --rm --name helloworld-vertx -p 8080:8080 helloworld-vertx:local
```

In another terminal:

```bash
curl --fail --include http://localhost:8080/
# HTTP 200, Content-Type: text/plain
# Body: Hello World: NOT SPECIFIED

docker stop helloworld-vertx
```

Test both a custom port and a custom greeting:

```bash
docker run --rm --name helloworld-vertx -p 9090:9090 \
  -e PORT=9090 -e 'TARGET=Eclipse Vert.x Sample v1' helloworld-vertx:local
```

In another terminal:

```bash
curl --fail http://localhost:9090/
# Exact body: Hello World: Eclipse Vert.x Sample v1

docker stop helloworld-vertx
```

## Publish and deploy to Knative

Replace `{username}` in these commands and in [service.yaml](service.yaml) with
your registry username. Build for your cluster's CPU architecture; Docker builds
for the local architecture by default. Use an explicit image tag in both places.

```bash
docker build -t docker.io/{username}/helloworld-vertx .
docker push docker.io/{username}/helloworld-vertx
```

The checked-in Service uses `TARGET=Eclipse Vert.x Sample v1`. Do not override
`PORT` in its environment unless you also configure the corresponding container
port in the Knative Service. Knative's default is 8080. For a custom Knative
port, use a non-reserved port such as 8081; 9090 and 9091 are reserved by
Knative even though they work for standalone Docker containers.

```bash
kubectl apply --filename service.yaml
kubectl wait --for=condition=Ready ksvc/helloworld-vertx --timeout=180s
kubectl get ksvc helloworld-vertx \
  --output=custom-columns=NAME:.metadata.name,URL:.status.url
```

Request the returned URL:

```bash
curl --fail "$(kubectl get ksvc helloworld-vertx -o jsonpath='{.status.url}')"
# Exact body: Hello World: Eclipse Vert.x Sample v1
```

To change the greeting, edit `TARGET` in `service.yaml` and apply it again. Knative
creates an immutable revision and routes traffic to it when ready. Serving also
supports scaling this application down to zero and reactivating it on demand.

## Clean up

```bash
kubectl delete --filename service.yaml
```

## Version and support references

- [Vert.x 5.2.2 source and release](https://github.com/eclipse-vertx/vert.x/tree/5.2.2)
  and [published versions](https://repo.maven.apache.org/maven2/io/vertx/vertx-core/maven-metadata.xml).
- [OpenJDK 21 LTS](https://openjdk.org/projects/jdk/21/) and public
  [Eclipse Temurin container images](https://github.com/adoptium/containers).
- [Apache Maven release/support history](https://maven.apache.org/docs/history.html).

These are public open-source toolchains; no commercial JDK subscription is
required. Java 21 is used consistently for compilation, testing, and runtime.
