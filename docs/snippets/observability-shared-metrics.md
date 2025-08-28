
## Knative Webhook Metrics

Webhook metrics report useful info about operations. For example, if a large number of operations fail, this could indicate an issue with a user-created resource.

### `http.server.request.duration`

Knative implements the [semantic conventions for HTTP Servers](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/#http-server) using the OpenTelemetry [otel-go/otelhttp](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) package.

Please refer to the [OpenTelemetry docs](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp) for details about the HTTP Server metrics it exports.

### `kn.webhook.handler.duration`

**Instrument Type:** Histogram
**Unit (UCUM):** s
**Description:** The duration of task execution.

*Attributes*

Name | Type | Description | Examples
-|-|-|-
`kn.webhook.type` | string | Specifies the type of webhook invoked | `admission`, `defaulting`, `validation`, `conversion` |
`kn.webhook.resource.group` | string | Specifies the resource Kubernetes group name |
`kn.webhook.resource.version` | string | Specifies the resource Kubernetes group version|
`kn.webhook.resource.kind` | string | Specifies the resource Kubernetes group kind |
`kn.webhook.subresource` | string | Specifies the subresource | "" (empty), `status`, `scale` |
`kn.webhook.operation.type` | string | Specifies the operation that invoked the webhook | `CREATE`, `UPDATE`, `DELETE` |
`kn.webhook.operation.status` | string | Specifies whether the operation was successful | `success`, `failed` |

## Knative Controller Metrics

## Go Runtime

Knative implements the [semantic conventions for Go runtime metrics](https://opentelemetry.io/docs/specs/semconv/runtime/go-metrics/) using the OpenTelemetry [otel-go/instrumentation/runtime](https://pkg.go.dev/go.opentelemetry.io/contrib/instrumentation/runtime) package. 

Please refer to the [OpenTelemetry docs](https://opentelemetry.io/docs/specs/semconv/runtime/go-metrics/) for details about the go runtime metrics it exports.
