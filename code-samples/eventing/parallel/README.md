# Parallel event routing: filters and switch cases

This tutorial sends a minute-scheduled CloudEvent through two Parallel branches,
transforms its data according to rounded timestamp parity, and displays the reply.
One small [Go helper](functions/README.md), one display Service and one PingSource
support **two alternative routing configurations**. Build the helper once; choose
one configuration, not two separate applications.

The data starts as `{"message":"Even or odd?"}`. A selected even branch returns
`{"message":"we are even!"}`; a selected odd branch returns
`{"message":"this is odd!"}`. Both configurations send transformer replies to the
same global `event-display` sink.

## Prerequisites

- Kubernetes with Knative Serving and Knative Eventing, including Parallel,
  PingSource and the InMemoryChannel implementation explicitly used here.
- Docker to build the helper image.
- `kubectl`, and `kind` only for the local-kind image workflow below.

Run the following commands from `code-samples/eventing/parallel/`.

## Build one helper image

Build the [Go helper image](functions/README.md):

```bash
IMAGE=dev.local/parallel-helpers:go-v1
docker build -t "$IMAGE" ./functions
```

### Local kind cluster

The supplied [helper Service](helpers.yaml) uses the local-development reference
`dev.local/parallel-helpers:go-v1` with `IfNotPresent`. Load that one image:

```bash
kind load docker-image "$IMAGE" --name <cluster-name>
```

Knative must skip remote tag resolution for the local prefix (`dev.local/` is
excluded by default). See
[skipping tag resolution](https://knative.dev/docs/serving/deploying-from-private-registry/#skipping-tag-resolution)
if your installation overrides this. Host Docker image presence alone is not
node image availability.

### Registry-backed cluster

The local reference is a convenience, not a required registry. For a normal
cluster, build/tag the same shared context for a registry accessible to its nodes:

```bash
IMAGE=registry.example.com/your-project/parallel-helpers:go-v1
docker build -t "$IMAGE" ./functions
docker push "$IMAGE"
```

Replace the single helper `image:` in [helpers.yaml](helpers.yaml) with this exact
reference before applying it; configure pull credentials if needed. Keep the
external [event-display image](event-display.yaml) unchanged. This path needs no
kind loading or local tag-resolution exception. Choose one image workflow, not
both, unless you need both targets.

## Create the common Services

Use the same namespace for every resource. All destinations use Service references
and relative handler URIs, so neither configuration hardcodes a namespace:

```bash
NAMESPACE=parallel-demo
kubectl create namespace "$NAMESPACE"
kubectl -n "$NAMESPACE" apply -f ./helpers.yaml -f ./event-display.yaml
kubectl -n "$NAMESPACE" wait ksvc/parallel-helpers ksvc/event-display \
  --for=condition=Ready --timeout=180s
```

[helpers.yaml](helpers.yaml) runs the one helper image. Every instance exposes all
six explicit paths; Parallel selects which operations execute. The shared
[event-display.yaml](event-display.yaml) logs the final events.

## Choose a routing configuration

Both files define the **same** `odd-even-parallel` resource. Apply exactly one.
They differ in filter paths, not their source, transformers or global reply:

| Configuration | First branch | Second branch | Manifest |
| --- | --- | --- | --- |
| Independent predicates | `/filter/even` → `/transform/even` | `/filter/odd` → `/transform/odd` | [parallel-filters.yaml](parallel-filters.yaml) |
| Explicit switch cases | `/switch/0` → `/transform/even` | `/switch/1` → `/transform/odd` | [parallel-switch.yaml](parallel-switch.yaml) |

### Filter routing

Each branch independently tests the rounded epoch-minute remainder. The even
predicate accepts remainder 0; the odd predicate accepts a nonzero remainder.
For this example the predicates are complementary, but Parallel itself does not
promise mutual exclusion between independent filters.

```bash
kubectl -n "$NAMESPACE" apply -f ./parallel-filters.yaml
```

### Switch routing

Alternatively, the two explicit case endpoints accept only remainder 0 or 1.
They select at most one subscriber for each event (subject to normal Eventing
redelivery, not an exactly-once delivery guarantee):

```bash
kubectl -n "$NAMESPACE" apply -f ./parallel-switch.yaml
```

For modern timestamps, both configurations produce the same even/odd messages.
Minute parity is calculated as
`Math.round(timestamp_ms / 60000) % 2`: millisecond precision, ties toward positive
infinity and signed remainder. At 29.999 seconds rounding uses the current
minute; at 30 seconds it uses the next minute. Before the Unix epoch, a negative
odd rounded minute has remainder -1: the odd **filter** accepts it, but neither
switch case matches. See the [rounding contract](functions/README.md#minute-rounding).

In either configuration a match returns the unchanged CloudEvent to its
subscriber. A no-match returns empty HTTP 200, with no event attributes/body and
therefore no subscriber or global reply for that branch. Transformers replace
only the data while preserving context/extensions. Binary and structured JSON
CloudEvents 1.0 are supported, with helper replies retaining input encoding.
Missing/invalid parity time returns 400. The helper contract also documents
request limits, errors, health checks and `PORT` (default 8080).

## Start the shared PingSource

After choosing one configuration, wait for it and apply the shared source:

```bash
kubectl -n "$NAMESPACE" wait parallel/odd-even-parallel \
  --for=condition=Ready --timeout=180s
kubectl -n "$NAMESPACE" apply -f ./ping-source.yaml
kubectl -n "$NAMESPACE" wait pingsource/ping-source \
  --for=condition=Ready --timeout=180s
```

[ping-source.yaml](ping-source.yaml) emits `{"message":"Even or odd?"}` every
minute, targeting `odd-even-parallel`, not a helper or display endpoint directly.

## Inspect behavior

Wait at least two minute ticks to observe both parities:

```bash
kubectl -n "$NAMESPACE" logs -l serving.knative.dev/service=event-display \
  --tail=100 -c user-container
```

The data alternates between `{"message":"we are even!"}` and
`{"message":"this is odd!"}`. The original PingSource ID, source, time and
`dev.knative.sources.ping` type remain attached to each reply. For example,
`2020-03-03T21:24:00Z` selects even and `2020-03-03T21:24:30Z` rounds to odd.

The helper logs show each received event's ID, path and `matched` decision:

```bash
kubectl -n "$NAMESPACE" logs -l serving.knative.dev/service=parallel-helpers \
  --tail=100 -c user-container
```

An even event reaches both `/filter/*` or both `/switch/*` paths, depending on the
configuration. Only the selected path has `matched:true`, and only its matching
`/transform/*` path receives that ID. A switch event with remainder -1 reaches both
case paths with `matched:false` and produces no transformer or display event.

## Switch configurations

Keep the helper image and common Services. To avoid changing routing while the
source is actively emitting, stop the source and remove the old Parallel first:

```bash
kubectl -n "$NAMESPACE" delete -f ./ping-source.yaml
kubectl -n "$NAMESPACE" delete parallel/odd-even-parallel --wait=true
# Choose the other routing file (use parallel-filters.yaml to switch back).
kubectl -n "$NAMESPACE" apply -f ./parallel-switch.yaml
kubectl -n "$NAMESPACE" wait parallel/odd-even-parallel \
  --for=condition=Ready --timeout=180s
kubectl -n "$NAMESPACE" apply -f ./ping-source.yaml
```

In-flight deliveries may finish under the previous routing configuration; this is
not a transactional update or durable/exactly-once processing guarantee. Use fresh
namespaces if you need isolated observations of the two configurations.

## Cleanup

These names remove whichever routing variant you selected:

```bash
kubectl -n "$NAMESPACE" delete pingsource/ping-source parallel/odd-even-parallel
kubectl -n "$NAMESPACE" delete -f ./helpers.yaml -f ./event-display.yaml
kubectl delete namespace "$NAMESPACE"
```
