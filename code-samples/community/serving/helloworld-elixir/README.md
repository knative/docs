# Hello World - Elixir

A [Phoenix](https://www.phoenixframework.org/) web application for Knative Serving.
It displays a greeting and an HTML-escaped `TARGET`. Only `TARGET`, `PORT`,
`K_SERVICE`, `K_REVISION`, and `K_CONFIGURATION` appear in its environment list.

## Build and run

Run from this sample directory:

```bash
docker build -t helloworld-elixir .
docker run --rm -p 127.0.0.1:8080:8080 \
  -e TARGET="elixir Sample v1" helloworld-elixir
```

In another terminal:

```bash
curl --fail http://localhost:8080/
```

The page includes `Welcome to Knative and Elixir` and `$TARGET = elixir Sample v1`.
The server listens on `PORT`, defaulting to `8080`.

## Deploy to Knative

With Knative Serving installed, build and push your image, replacing `{username}`:

```bash
docker buildx build --platform linux/arm64,linux/amd64 \
  -t "docker.io/{username}/helloworld-elixir" --push .
```

Set the image in [service.yaml](service.yaml) to the same reference, then deploy:

```bash
kubectl apply --filename service.yaml
kubectl wait --for=condition=Ready ksvc/helloworld-elixir --timeout=180s
SERVICE_URL=$(kubectl get ksvc helloworld-elixir -o jsonpath='{.status.url}')
curl --fail "$SERVICE_URL"
```

## Cleanup

```bash
kubectl delete --filename service.yaml
```
