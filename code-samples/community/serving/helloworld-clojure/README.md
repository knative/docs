# Hello World - Clojure

A Clojure HTTP service using Ring and Jetty on Java 25. It returns
`Hello ${TARGET}!` followed by a newline. `TARGET` defaults to `World`, and
`PORT` defaults to `8080`.

The [source](src/helloworld/core.clj) and [dependencies](project.clj) are built
into an executable jar by the [Dockerfile](Dockerfile); the runtime image
contains only a Java 25 JRE and the application jar.

## Build and run locally

From this directory, with Docker running:

```bash
docker build -t helloworld-clojure .
docker run --rm -p 8080:8080 helloworld-clojure
# In another terminal:
curl http://localhost:8080
# Hello World!
```

Set `TARGET` or `PORT` with Docker's `-e` option. If you change `PORT`, also
update the container port in your `-p` mapping.

## Deploy to Knative

Use a cluster with [Knative Serving](https://knative.dev/docs/install/) and
networking configured, and a Docker Hub account. Replace `{username}` below
and in [service.yaml](service.yaml) with your Docker Hub username.

```bash
docker buildx build --platform linux/arm64,linux/amd64 -t "{username}/helloworld-clojure" --push .
kubectl apply -f service.yaml
kubectl wait --for=condition=Ready service.serving.knative.dev/helloworld-clojure --timeout=300s
curl "$(kubectl get ksvc helloworld-clojure -o jsonpath='{.status.url}')"
# Hello Clojure Sample v1!
```

The manifest sets `TARGET` to `Clojure Sample v1`. Remove the sample with:

```bash
kubectl delete -f service.yaml
```
