# Go CloudEvents with a Broker and Triggers

This example runs the [Go CloudEvents receiver](../README.md) as a Kubernetes
Deployment and Service. Serving is not
required for this variant. A Broker accepts input, a filtered Trigger delivers
it to the receiver, and the receiver's reply becomes a new event in the Broker.
A second Trigger routes that reply to an event logger. This demonstrates
[Broker](https://knative.dev/docs/eventing/brokers/) and
[Trigger](https://knative.dev/docs/eventing/triggers/) routing without confusing
an HTTP acknowledgement from the Broker with actual subscriber delivery.

## Event format

| Field | Value |
| --- | --- |
| Input data | `{"name":"Dave"}` |
| Input routing attributes | `type=curl.demo`, `source=curl-command` |
| Reply type | `dev.knative.docs.sample` |
| Reply source | `https://github.com/knative/docs/code-samples/serving/cloudevents/cloudevents-go` |
| Reply data | `{"message":"Hello, Dave"}` |

Binary and structured CloudEvents v1 are supported. The input Trigger filters
on both input type and source; generated replies have a different type, so they
are not routed back to the receiver in a loop. Each reply receives a fresh ID
and timestamp from the SDK.

## Prerequisites and source files

- Kubernetes with [Knative Eventing](https://knative.dev/docs/install/eventing/install-eventing-with-yaml/),
  including MTChannelBasedBroker and InMemoryChannel, installed.
- Docker and an image registry reachable by your cluster, or a local kind image
  import setup. No third-party API credentials are used.
- `kubectl` configured for your intended test cluster.

Clone and enter the sample directory:

```bash
git clone https://github.com/knative/docs.git knative-docs
cd knative-docs/code-samples/serving/cloudevents/cloudevents-go
```

Use the checked-in [Broker/receiver/input Trigger manifest](sample-app.yaml),
[event-display Deployment and Service](event-display.yaml), and
[output Trigger](reply-trigger.yaml). The event-display image is a small local
logger built from [its source](logger/capture.go) and
[Dockerfile](logger/Dockerfile).

## Build and deploy

Build the receiver with Docker using the [build instructions](../README.md).
Set `image:` in the Deployment in `eventing/sample-app.yaml` to that image.
Also build the logger:

```bash
docker build -t <event-display-image> eventing/logger
docker push <event-display-image>
```

Replace the placeholder image in `eventing/event-display.yaml` with your logger
image. For kind, importing both locally built images with `kind load docker-image`
and using non-latest tags with `imagePullPolicy: IfNotPresent` avoids a registry
push. Do not change shared cluster image-resolution settings.

From the sample root:

```bash
kubectl create namespace knative-samples
kubectl -n knative-samples apply -f eventing/sample-app.yaml
kubectl -n knative-samples apply -f eventing/event-display.yaml
kubectl -n knative-samples apply -f eventing/reply-trigger.yaml
kubectl -n knative-samples rollout status deployment/cloudevents-go-eventing --timeout=180s
kubectl -n knative-samples rollout status deployment/event-display --timeout=180s
kubectl -n knative-samples wait broker/default --for=condition=Ready --timeout=180s
kubectl -n knative-samples wait trigger/input-to-sample trigger/output-to-capture --for=condition=Ready --timeout=180s
```

If `knative-samples` already exists, use your own test namespace consistently
rather than deleting someone else's resources. The manifests deliberately omit
namespaces so `kubectl -n` selects the intended namespace.

## Send binary and structured events

Get the actual Broker URL:

```bash
BROKER_URL=$(kubectl -n knative-samples get broker default -o jsonpath='{.status.address.url}')
```

The URL is normally cluster-internal. Send from a temporary curl pod; these
commands return HTTP 202 on Broker acceptance (not a synchronous greeting):

```bash
kubectl -n knative-samples run send-binary --rm -i --restart=Never --image=curlimages/curl:8.17.0 -- \
  --fail-with-body -i "$BROKER_URL" -X POST \
  -H 'content-type: application/json' -H 'ce-specversion: 1.0' \
  -H 'ce-type: curl.demo' -H 'ce-source: curl-command' -H 'ce-id: tutorial-binary' \
  -d '{"name":"Dave"}'
kubectl -n knative-samples run send-structured --rm -i --restart=Never --image=curlimages/curl:8.17.0 -- \
  --fail-with-body -i "$BROKER_URL" -X POST -H 'content-type: application/cloudevents+json' \
  -d '{"specversion":"1.0","id":"tutorial-structured","type":"curl.demo","source":"curl-command","datacontenttype":"application/json","data":{"name":"Dave"}}'
```

Check **both** processing and output delivery:

```bash
kubectl -n knative-samples logs deployment/cloudevents-go-eventing --tail=50
kubectl -n knative-samples logs deployment/event-display --tail=50
```

The receiver logs `Got an event from: "Dave"` and `Replying with event: "Hello, Dave"`.
The logger records the generated CloudEvent headers, including
`Ce-Type: dev.knative.docs.sample`, the reply source above, a new ID, and JSON data
`{"message":"Hello, Dave"}`. That proves Broker → input Trigger → receiver reply
→ Broker → output Trigger → logger, beyond simply observing HTTP 202.

Try changing the input source/type to understand why nonmatching events are not
delivered by the input Trigger. Do not change the output filter to match input
attributes: it must select the receiver's generated reply.

## Explicit sink mode and port configuration

Normally the receiver returns a CloudEvent in the HTTP response to its caller;
Eventing republishes that reply. A nonempty `K_SINK` instead makes the receiver
explicitly send its output to the selected destination and acknowledge its caller
without a response event. For example, forward output explicitly to this Broker:

```bash
kubectl -n knative-samples set env deployment/cloudevents-go-eventing K_SINK="$BROKER_URL"
kubectl -n knative-samples rollout status deployment/cloudevents-go-eventing --timeout=180s
```

Send another binary or structured input as above and verify the logger again.
The output Trigger still selects `dev.knative.docs.sample`. Reset reply mode:

```bash
kubectl -n knative-samples set env deployment/cloudevents-go-eventing K_SINK-
kubectl -n knative-samples rollout status deployment/cloudevents-go-eventing --timeout=180s
```

Unset or empty `K_SINK` means reply mode. A failing sink returns an unsuccessful
HTTP response, rather than silently acknowledging successful delivery. The default
port is 8080; if setting `PORT` on this Deployment, update the Service `targetPort`
and container port consistently. The [Serving example](../README.md) documents the same port configuration.

## Cleanup

Delete only the resources you created:

```bash
kubectl -n knative-samples delete -f eventing/reply-trigger.yaml
kubectl -n knative-samples delete trigger/input-to-sample broker/default
kubectl -n knative-samples delete deployment/cloudevents-go-eventing service/cloudevents-go-eventing
kubectl -n knative-samples delete -f eventing/event-display.yaml
# Only if you created this otherwise-unused namespace:
kubectl delete namespace knative-samples
```
