# Knative multi-container sample

This Go web app demonstrates a serving container calling a sidecar over the
shared Pod network. The serving container listens on port 8881 and the sidecar
on port 8882. Requests return `Yay!! multi-container works`.
These ports are fixed in the source; setting the `PORT` environment variable
does not override them. Keep `containerPort: 8881` in the Service manifest.

## Prerequisites

- A Kubernetes cluster with [Knative Serving installed](https://knative.dev/docs/install/serving/install-serving-with-yaml)
  and DNS configured.
- Docker installed and running, and a container registry you can push images to.
- If your Knative version gates multi-container support, enable the
  `multi-container` feature in the `config-features` ConfigMap.

## Build the sample

Clone the repository and enter the sample directory:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/multi-container
```

Use the checked-in files rather than recreating them from snippets:

- Serving container: [Go source](servingcontainer/servingcontainer.go),
  [Dockerfile](servingcontainer/Dockerfile), and [module](servingcontainer/go.mod).
- Sidecar container: [Go source](sidecarcontainer/sidecarcontainer.go),
  [Dockerfile](sidecarcontainer/Dockerfile), and [module](sidecarcontainer/go.mod).
- Knative Service: [service.yaml](service.yaml).

No local Go installation or `go mod init` is necessary.

Build and push both images, replacing `username` with your Docker Hub username:

```bash
export DOCKER_HUB_USERNAME=username
docker buildx build --platform linux/arm64,linux/amd64 \
  -t "${DOCKER_HUB_USERNAME}/servingcontainer" --push ./servingcontainer
docker buildx build --platform linux/arm64,linux/amd64 \
  -t "${DOCKER_HUB_USERNAME}/sidecarcontainer" --push ./sidecarcontainer
```

## Test locally with Docker

Build native images locally without publishing them:

```bash
docker build -t servingcontainer ./servingcontainer
docker build -t sidecarcontainer ./sidecarcontainer
```

Use a shared network namespace to reproduce the Pod's localhost networking:

```bash
docker run -d --name knative-sample-sidecar -p 127.0.0.1:8881:8881 sidecarcontainer
docker run -d --name knative-sample-serving \
  --network container:knative-sample-sidecar servingcontainer
curl --fail http://127.0.0.1:8881
# Yay!! multi-container works
```

If the sidecar is unavailable, returns a non-200 status, or takes longer than
five seconds to respond, the serving container returns HTTP 502 instead of
terminating. Retry once both containers have started.

Clean up the local containers:

```bash
docker rm -f knative-sample-serving knative-sample-sidecar
```

## Deploy to Knative

Replace both `{username}` placeholders in [service.yaml](service.yaml) with your registry
username, matching the images you pushed. The manifest exposes only port 8881;
the containers communicate over `127.0.0.1:8882` inside the Pod.

```bash
kubectl apply --filename service.yaml
kubectl wait --for=condition=Ready ksvc/multi-container --timeout=120s
kubectl get ksvc multi-container --output=custom-columns=NAME:.metadata.name,URL:.status.url
```

Request the URL returned above:

```bash
curl --fail "$(kubectl get ksvc multi-container -o jsonpath='{.status.url}')"
# Yay!! multi-container works
```

Knative creates an immutable Revision, configures routing, and scales the Pod
containing both containers based on traffic, including scaling to zero.

## Clean up the deployment

```bash
kubectl delete --filename service.yaml
```
