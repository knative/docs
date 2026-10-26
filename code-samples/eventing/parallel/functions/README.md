# Go helpers for Parallel routing

A Go HTTP application uses the [CloudEvents Go SDK](https://github.com/cloudevents/sdk-go)
for the filter, switch and transform operations in the [Parallel tutorial](../README.md).

| POST path | Operation |
| --- | --- |
| `/filter/even` | Return the input event when the rounded minute remainder is 0. |
| `/filter/odd` | Return the input event when the remainder is not 0. |
| `/switch/0` | Return the input event only when the remainder equals case 0. |
| `/switch/1` | Return the input event only when the remainder equals case 1. |
| `/transform/even` | Replace data with `{"message":"we are even!"}`. |
| `/transform/odd` | Replace data with `{"message":"this is odd!"}`. |

Every instance exposes all six paths; the Parallel destinations select their
paths. A filter/switch no-match returns HTTP **200 with no event headers or body**,
so that branch has no reply. Accepted filters/switches preserve the event context and data.
Transformers preserve event context and extensions while replacing the data and
setting its content type to `application/json`.

Both **binary** and **structured JSON** CloudEvents 1.0 are supported, and replies
retain the input encoding. Binary responses copy CloudEvent attributes, not
request transport/authorization headers. Structured responses preserve attributes
(including extensions), replacing `data` and removing `data_base64` when
transforming. Event bodies are limited to 1 MiB. Missing required context,
unsupported specversion, malformed structured JSON or invalid/missing parity time
return HTTP 400. Transformers do not need a time attribute. Unknown paths return
404; event paths require POST (otherwise 405).

## Minute rounding

Event timestamps are rounded to the nearest minute, with ties rounded toward
positive infinity. At 29.999 seconds the current minute is used; at 30 seconds
the next minute is used. Before the Unix epoch, an odd rounded minute has
remainder -1: `/filter/odd` matches it but `/switch/1` does not. Invalid timestamps
return HTTP 400.

## Build

Run from `code-samples/eventing/parallel/` to build the helper image:

```bash
IMAGE=dev.local/parallel-helpers:go-v1
docker build -t "$IMAGE" ./functions
```

Go dependencies are recorded in `go.mod` and `go.sum`.

`PORT` defaults to **8080** and can be changed, for example:

```bash
docker run --rm -e PORT=9090 -p 127.0.0.1:9090:9090 dev.local/parallel-helpers:go-v1
```

`GET /healthz` returns 200. Event operations log the event ID, path and match
decision. Follow the tutorial's [filter routing](../README.md#filter-routing) or
[switch routing](../README.md#switch-routing) instructions to deploy.
