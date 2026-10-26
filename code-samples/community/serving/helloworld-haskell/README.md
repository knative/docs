# Hello World - Haskell

A small Knative Serving application. `GET /` returns `Hello ${TARGET}` as UTF-8
plain text, without punctuation or a trailing newline. Unset `TARGET` defaults
to `World`; an explicitly empty `TARGET` returns `Hello `. `PORT` defaults to
`8080`. The server accepts connections from outside the container.

## Prerequisites

- Docker with BuildKit, and a Kubernetes cluster with
  [Knative Serving](https://knative.dev/docs/install/) and ingress configured.
- A container registry account if pushing the image for a remote cluster.
  A local kind cluster can instead load a locally built image.
- No local Haskell installation is needed; the Dockerfile includes the toolchain.

## Sample files

[`Dockerfile`](Dockerfile) builds [`app/Main.hs`](app/Main.hs) using Cabal and
[`cabal.project.freeze`](cabal.project.freeze). The runtime image runs as non-root.
The sample is licensed under [Apache 2.0](LICENSE).
Invalid, zero, or out-of-range `PORT` values fail at startup.

## Build and run locally

Run these commands from the sample directory. Use your cluster node's platform
(`linux/arm64` below; substitute `linux/amd64` for x86-64 nodes).

```bash
docker build --platform linux/arm64 -t helloworld-haskell:local .
docker run --rm -p 127.0.0.1:8080:8080 --memory 128m --cpus 1 helloworld-haskell:local
# In another terminal:
curl -fsS http://127.0.0.1:8080/
```

The build runs `cabal check` and compiles with warnings as errors. To use another
environment, start the image with `-e TARGET='Haskell Sample v1' -e PORT=8081`
and publish `127.0.0.1:8081:8081`, then request that port with curl.

## Deploy to Knative

Set your Docker Hub username in the image tag and in `service.yaml`. Build and
push only when you intend to publish:

```bash
IMAGE=docker.io/{username}/helloworld-haskell
docker build --platform linux/arm64 -t "$IMAGE" .
docker push "$IMAGE"
```

Use the checked-in [`service.yaml`](service.yaml). Its `TARGET` value is
`Haskell Sample v1`; replace only the image username/tag and, if needed, namespace
before applying it.

For a local kind cluster, use a non-latest local reference (for example,
`dev.local/helloworld-haskell:local`), load it with `kind load docker-image`,
and set `imagePullPolicy: IfNotPresent`. Knative must be configured to skip remote
tag resolution for that local registry prefix. Adapt `metadata.namespace` when
using an isolated namespace.

Knative injects `PORT`. To select another port, set
`spec.template.spec.containers[0].ports[0].containerPort`, for example `8081`.

```bash
kubectl apply --filename service.yaml
kubectl wait --for=condition=Ready ksvc/helloworld-haskell --timeout=180s
kubectl get ksvc helloworld-haskell -o jsonpath='{.status.url}'
```

Request the returned URL through your cluster ingress:

```bash
curl http://helloworld-haskell.default.1.2.3.4.sslip.io
# Exact body: Hello Haskell Sample v1 (no trailing newline)
```

To remove the deployment:

```bash
kubectl delete --filename service.yaml
```
