# Hello World — Python

This app uses the [CloudEvents Python SDK](https://github.com/cloudevents/sdk-python)
to decode binary or structured CloudEvents and return a new CloudEvent 1.0.
Gunicorn listens on `PORT` (default `8080`).

## Build and run

From this directory:

```sh
docker build -t helloworld-python .
docker run --rm -p 8080:8080 helloworld-python
```

Send a CloudEvent in another terminal:

```sh
curl -i http://localhost:8080/ \
  -H 'Ce-Id: hello-python' -H 'Ce-Specversion: 1.0' \
  -H 'Ce-Type: dev.knative.samples.helloworld' \
  -H 'Ce-Source: dev.knative.samples/helloworldsource' \
  -H 'Content-Type: application/json' -d '{"msg":"Hello World!"}'
```

The response contains the JSON message `Hi from helloworld-python app!` and SDK-generated
CloudEvent headers with type `dev.knative.samples.hifromknative` and source
`knative/eventing/samples/hello-world`.

## Publish and deploy

Use a cluster with Knative Serving, Eventing, InMemoryChannel and the
MTChannelBasedBroker installed. Build and push your image, replacing `{username}`:

```sh
docker buildx build --platform linux/arm64,linux/amd64 \
  -t docker.io/{username}/helloworld-python --push .
```

Set that image in [`sample-app.yaml`](sample-app.yaml), then deploy the native
Broker, app, reply receiver and Triggers:

```sh
kubectl apply -f sample-app.yaml
kubectl -n knative-samples wait --for=condition=Ready --timeout=300s \
  ksvc/helloworld-python ksvc/event-display broker/default \
  trigger/helloworld-python trigger/event-display
```

Publish an event to the Broker from a temporary curl Pod:

```sh
BROKER_URL=$(kubectl -n knative-samples get broker default -o jsonpath='{.status.address.url}')
kubectl -n knative-samples run curl --image=curlimages/curl --restart=Never --command -- sleep 300
kubectl -n knative-samples wait --for=condition=Ready pod/curl --timeout=120s
kubectl -n knative-samples exec curl -- curl -i "$BROKER_URL" \
  -H 'Ce-Id: hello-python' -H 'Ce-Specversion: 1.0' \
  -H 'Ce-Type: dev.knative.samples.helloworld' \
  -H 'Ce-Source: dev.knative.samples/helloworldsource' \
  -H 'Content-Type: application/json' -d '{"msg":"Hello World!"}'
kubectl -n knative-samples delete pod curl
```

The Broker returns HTTP 202. Its input Trigger delivers the event to the Python
app; a second Trigger routes the app's reply to the stock `event-display` receiver.
Check for the reply type, source and message:

```sh
kubectl -n knative-samples logs -l serving.knative.dev/service=event-display -c user-container --tail=50
```

Remove the sample, including its namespace:

```sh
kubectl delete -f sample-app.yaml
```
