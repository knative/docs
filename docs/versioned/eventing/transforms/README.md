# Event Transformation

## Overview

`EventTransform` is a Knative API resource that enables declarative transformations of HTTP requests and responses
without requiring custom code. It allows you to modify event attributes, extract data from event payloads, and reshape
events to fit different systems' requirements.

EventTransform is designed to be a flexible component in your event-driven architecture that can be placed at various
points in your event flow to facilitate seamless integration between diverse systems.

## Key Features

- **Declarative transformations** using standard Kubernetes resources
- **JSONata expressions** for powerful data extraction and transformation
- **Addressable resource** that can be referenced from any Knative source, trigger, or subscription
- **Flexible deployment options** within your event flow
- **Sink configuration** to direct transformed events to specific destinations
- **Reply support** to leverage Broker's built-in reply feature

## Common Use Cases

### Field Extraction

Extract specific fields from event payloads and promote them as CloudEvent attributes for filtering:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: extract-user-id
spec:
  jsonata:
    expression: |
      {
        "specversion": "1.0",
        "id": id,
        "type": "user.extracted",
        "source": "transform.user-extractor",
        "time": time,
        "userid": data.user.id,
        "data": $
      }
```

### Event Format Conversion

Transform events from one format to another to ensure compatibility between systems:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: format-converter
spec:
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: destination-service
  jsonata:
    expression: |
      {
        "specversion": "1.0",
        "id": id,
        "type": "order.converted",
        "source": "transform.format-converter",
        "time": time,
        "data": {
          "orderId": data.id,
          "customer": {
            "name": data.user.fullName,
            "email": data.user.email
          },
          "items": data.items
        }
      }
```

### Event Enrichment

Add additional context or metadata to events:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: event-enricher
spec:
  jsonata:
    expression: |
      {
        "specversion": "1.0",
        "id": id,                     /* Add the "id", "type", "source", and "time" attributes based on the input JSON object fields */
        "type": type,
        "source": source,
        "time": time,                 
        "environment": "production",  /* Add fixed environment and region attributes to the event metadata */
        "region": "us-west-1",        
        "data": $                     /* Add the event transform input JSON body as CloudEvent "data" field */
      }
```

### Event Response Reply Transformation

When using the EventTransform with a sink, you can also transform the responses from the sink:

!!! important
    The same type of transformation must be used for Sink and Reply transformations.

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: request-reply-transform
spec:
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: processor-service
  jsonata:
    expression: |
      # Request transformation
      {
        "specversion": "1.0",
        "id": id,
        "type": "request.transformed",
        "source": source,
        "time": time,
        "data": data
      }
  reply:
    jsonata:
      expression: |
        # Reply transformation
        {
          "specversion": "1.0",
          "id": id,
          "type": "reply.transformed",
          "source": "transform.reply-processor",
          "time": time,
          "data": data
        }
```

## Deployment Patterns

EventTransform can be used in different positions within your event flow:

### Source → EventTransform → Broker

Transform events before they reach the Broker:

```yaml
apiVersion: sources.knative.dev/v1
kind: ApiServerSource
metadata:
  name: k8s-events
spec:
  serviceAccountName: event-watcher
  resources:
    - apiVersion: v1
      kind: Event
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: EventTransform
      name: event-transformer
---
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: event-transformer
spec:
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1
      kind: Broker
      name: default
  jsonata:
    expression: |
      # transformation expression
```

### Broker → Trigger → EventTransform → Service or Sink

Transform events after they're filtered by a Trigger:

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: transform-trigger
spec:
  broker: default
  filter:
    attributes:
      type: original.event.type
  subscriber:
    ref:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: EventTransform
      name: event-transformer
---
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: event-transformer
spec:
  sink:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: destination-service
  jsonata:
    expression: |
      # transformation expression
```

### Using Broker Reply Feature

Transform events and republish them back to the Broker:

!!! important
    Preventing infinite event loops: When using the reply feature with a Broker, you must ensure that your transformed
    events don't trigger the same Trigger that sent them to the EventTransform in the first place.

```yaml
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: transform-trigger
spec:
  broker: default
  filter:
    attributes:
      type: original.event.type
  subscriber:
    ref:
      apiVersion: eventing.knative.dev/v1alpha1
      kind: EventTransform
      name: event-transformer
---
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: event-transformer
spec:
  # No sink specified - will use reply feature
  jsonata:
    expression: |
      {
        "specversion": "1.0",
        "id": id,
        "time": time,
        "type": "transformed.event.type",
        "source": "transform.event-transformer",
        "data": $
      }
```

## Next Steps

- [JSONata Transformations](./event-transform-jsonata.md) - Learn about using JSONata expressions for event
  transformations
- [Trigger Filtering](./../triggers/README.md#trigger-filtering) - Learn how to use Trigger filtering
- [EventTransform API Reference](./../reference/eventing-api.md) - Detailed API reference for EventTransform
