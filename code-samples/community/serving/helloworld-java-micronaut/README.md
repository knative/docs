# Hello World — Java (Micronaut)

Deploy a plain-text HTTP service using Micronaut Platform **5.2.3** and
**Java 25 LTS**. GET `/` returns `Hello World: ${TARGET}` without a trailing
newline. An unset `TARGET` defaults to `NOT SPECIFIED`; an explicitly empty
`TARGET` stays empty. The listening port is `${PORT:8080}`.

## Requirements

- Docker with BuildKit for builds and optional multi-platform publication.
- curl for HTTP checks.
- A Knative Serving cluster and kubectl for deployment.
- A container registry account if publishing to a remote cluster.

Java, Maven and the Micronaut CLI do not need to be installed on the host.
Clone [knative/docs](https://github.com/knative/docs) and work in
`code-samples/community/serving/helloworld-java-micronaut`.

## Configuration

[`pom.xml`](pom.xml) uses the Micronaut parent and Java 25 to build an executable
JAR. [`application.yml`](src/main/resources/application.yml) configures the
application name and `${PORT:8080}` listening port.

## Build and run locally

The checked-in [Dockerfile](Dockerfile) builds the executable JAR.
Its production stage contains only the Java runtime and application and runs as a
non-root UID.

```sh
docker build -t helloworld-java-micronaut:local .
```

Start the actual production image, then request it from another terminal:

```sh
docker run --rm --name helloworld-java-micronaut-local -p 8080:8080 helloworld-java-micronaut:local
curl -fsS http://localhost:8080/
# Hello World: NOT SPECIFIED
```

Stop that container before starting the custom configuration:

```sh
docker run --rm --name helloworld-java-micronaut-local -p 8081:8081 \
  -e PORT=8081 -e TARGET="Micronaut Sample v1" helloworld-java-micronaut:local
curl -fsS http://localhost:8081/
# Hello World: Micronaut Sample v1
```

## Publish and deploy to Knative

Replace `{username}` in [`service.yaml`](service.yaml) and the image tag below with your registry
namespace. Publication requires credentials and is separate from local validation.

```sh
docker buildx build --platform linux/arm64,linux/amd64 \
  -t "{username}/helloworld-java-micronaut" --push .
kubectl apply --filename service.yaml
kubectl wait --for=condition=Ready ksvc/helloworld-java-micronaut --timeout=180s
kubectl get ksvc helloworld-java-micronaut -o jsonpath='{.status.url}'
```

The checked-in [Knative Service manifest](service.yaml) sets
`TARGET="Micronaut Sample v1"` and leaves the namespace selectable by kubectl.

Request the actual URL returned by kubectl:

```sh
curl -fsS http://helloworld-java-micronaut.default.1.2.3.4.sslip.io/
# Hello World: Micronaut Sample v1
```

For a different Knative container port, add `ports: [{containerPort: 8081}]`
to the container. Knative injects `PORT` automatically; do not explicitly set
that reserved environment variable or use reserved port 9090. To check the
default greeting, remove the `TARGET` entry, apply again, wait for the new revision
to become Ready and request the same route. It should return
`Hello World: NOT SPECIFIED`.

For an isolated kind cluster, use the same production image loaded into its node,
a non-latest local tag such as `dev.local/helloworld-java-micronaut:validation`,
and `imagePullPolicy: IfNotPresent`. The local registry prefix must already be
excluded from Knative tag resolution. This adaptation does not verify remote
publication, public DNS or TLS.

## Cleanup

```sh
kubectl delete --filename service.yaml
```
