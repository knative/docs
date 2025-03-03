# Event Transformations for JSON with JSONata

## Introduction to JSONata

[JSONata](https://jsonata.org/) is a lightweight query and transformation language for JSON data. In Knative EventTransform, JSONata expressions allow you to:

- Extract values from event data
- Promote data fields to CloudEvent attributes
- Restructure event payloads
- Add computed values
- Apply conditional logic

## Basic Usage

To use JSONata in an EventTransform resource, specify the expression in the `spec.jsonata.expression` field:

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: simple-transform
spec:
  jsonata:
    expression: |
      {
        "specversion": "1.0",
        "id": id,
        "time": time,
        "type": "transformed.type",
        "source": "transform.simple",
        "data": data
      }
```

## CloudEvent Structure

The input to the JSONata expression is the entire CloudEvent, including all its attributes and data. Your expression must produce a valid CloudEvent with at least these required fields:

- `specversion`: Should be set to "1.0"
- `id`: A unique identifier for the event
- `type`: The event type
- `source`: The event source
- `data`: The event payload

## Common Transformation Patterns

### Preserving Original Event Structure

To preserve the original event structure while adding or modifying attributes:

```jsonata
{
  "specversion": "1.0",
  "id": id,
  "type": type,
  "source": source,
  "time": time,
  "data": data,
  "newattribute": "static value"
}
```

### Extracting Fields as Attributes

To extract fields from the data and promote them to CloudEvent attributes:

```jsonata
{
  "specversion": "1.0",
  "id": id,
  "type": "user.event",
  "source": source,
  "time": time,
  "userid": data.user.id,
  "region": data.region,
  "data": $
}
```

The `$` symbol in JSONata represents the entire input object, so `data: $` preserves the entire original event data.

### Restructuring Event Data

To completely reshape the event data:

```jsonata
{
  "specversion": "1.0",
  "id": order.id,
  "type": "order.transformed",
  "source": "transform.order-processor",
  "time": order.time,
  "orderid": order.id,
  "data": {
    "customer": {
      "id": order.user.id,
      "name": order.user.name
    },
    "items": order.items.{ "sku": sku, "quantity": qty, "price": price },
    "total": $sum(order.items.(price * qty))
  }
}
```

Given the transformation above, and this JSON object as input:

```json
{
  "order": {
    "time" : "2024-04-05T17:31:05Z",
    "id": "8a76992e-cbe2-4dbe-96c0-7a951077089d",
    "user": {
      "id": "bd9779ef-cba5-4ad0-b89b-e23913f0a7a7",
      "name": "John Doe"
    },
    "items": [
      {"sku": "KNATIVE-1", "price": 99.99, "qty": 1},
      {"sku": "KNATIVE-2", "price": 129.99, "qty": 2}
    ]
  }
}

```

It would produce:

```json
{
  "specversion": "1.0",
  "id": "8a76992e-cbe2-4dbe-96c0-7a951077089d",
  "type": "order.transformed",
  "source": "transform.order-processor",
  "time": "2024-04-05T17:31:05Z",
  "orderid": "8a76992e-cbe2-4dbe-96c0-7a951077089d",
  "data": {
    "customer": {
      "id": "bd9779ef-cba5-4ad0-b89b-e23913f0a7a7",
      "name": "John Doe"
    },
    "items": [
      {
        "sku": "KNATIVE-1",
        "quantity": 1,
        "price": 99.99
      },
      {
        "sku": "KNATIVE-2",
        "quantity": 2,
        "price": 129.99
      }
    ],
    "total": 359.97
  }
}

```

### Conditional Transformations

To apply different transformations based on conditions:

```jsonata
{
  "specversion": "1.0",
  "id": id,
  "type": type = "order.created" ? "new.order" : "updated.order",
  "source": source,
  "time": time,
  "priority": data.total > 1000 ? "high" : "normal",
  "data": $
}
```

## Advanced JSONata Features

### Array Processing

JSONata makes it easy to process arrays in your event data:

```jsonata
{
  "specversion": "1.0",
  "id": id,
  "type": "order.processed",
  "source": source,
  "time": $now(),
  "itemcount": $count(order.items),
  "multiorder": $count(order.items) > 1,
  "data": {
    "order": order.id,
    "items": order.items[quantity > 1].{
      "product": name,
      "quantity": quantity,
      "lineTotal": price * quantity
    },
    "totalvalue": $sum(order.items.(price * quantity))
  }
}
```

Given the transformation above, and this JSON object as input:

```json
{
  "id": "12345",
  "source": "https://example.com/orders",
  "order": {
    "id": "order-67890",
    "items": [
      {
        "name": "Laptop",
        "price": 1000,
        "quantity": 1
      },
      {
        "name": "Mouse",
        "price": 50,
        "quantity": 2
      },
      {
        "name": "Keyboard",
        "price": 80,
        "quantity": 3
      }
    ]
  }
}
```

It would produce:

```json
{
  "specversion": "1.0",
  "id": "12345",
  "type": "order.processed",
  "source": "https://example.com/orders",
  "time": "2025-03-03T09:13:23.753Z",
  "itemcount": 3,
  "multiorder": true,
  "data": {
    "order": "order-67890",
    "items": [
      {
        "product": "Mouse",
        "quantity": 2,
        "lineTotal": 100
      },
      {
        "product": "Keyboard",
        "quantity": 3,
        "lineTotal": 240
      }
    ],
    "totalvalue": 1340
  }
}
```

### Using Built-in Functions

JSONata provides many useful functions:

```jsonata
{
  "specversion": "1.0",
  "id": id,
  "type": "user.event",
  "source": source,
  "time": time,
  "timestamp": $now(),
  "username": $lowercase(data.user.name),
  "initials": $join($map($split(data.user.name, " "), function($v) { $substring($v, 0, 1) }), ""),
  "data": $
}
```

## Transforming Replies

When using the EventTransform with a sink, you can also transform the responses:

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

## Best Practices

1. **Always produce valid CloudEvents**: Ensure your expressions include all required CloudEvent fields.

2. **Test expressions thoroughly**: Use the [JSONata Exerciser](https://try.jsonata.org/) to validate complex expressions.

3. **Keep expressions readable**: Use line breaks and indentation in your YAML to make expressions easier to read and maintain.

4. **Handle missing data**: Use the `?` operator to provide default values for potentially missing fields.

5. **Avoid infinite loops**: When using the reply feature with a Broker, make sure to change the event type or add filters to prevent infinite loops.

## Examples

### User Registration Event Transformer

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: user-registration-transformer
spec:
  sink:
    ref:
      apiVersion: eventing.knative.dev/v1
      kind: Broker
      name: default
  jsonata:
    expression: |
      {
        "specversion": "1.0",
        "id": id,
        "type": "user.registered.processed",
        "source": "transform.user-processor",
        "time": time,
        "userid": data.user.id,
        "region": data.region ? data.region : "unknown",
        "tier": data.subscription.tier ? data.subscription.tier : "free",
        "data": {
          "userId": data.user.id,
          "email": $lowercase(data.user.email),
          "displayName": data.user.name ? data.user.name : $substring(data.user.email, 0, $indexOf(data.user.email, "@")),
          "registrationDate": $now(),
          "subscription": data.subscription ? data.subscription : { "tier": "free" }
        }
      }
```

### Order Processing Event Transformer

```yaml
apiVersion: eventing.knative.dev/v1alpha1
kind: EventTransform
metadata:
  name: order-processor
spec:
  jsonata:
    expression: |
      {
        "specversion": "1.0",
        "id": id,
        "type": "order.processed",
        "source": "transform.order-processor",
        "time": time,
        "orderid": data.id,
        "customerid": data.customer.id,
        "region": data.region,
        "priority": $sum(data.items.(price * quantity)) > 1000 ? "high" : "standard",
        "data": {
          "orderId": data.id,
          "customer": data.customer,
          "items": data.items.{
            "productId": productId,
            "name": name,
            "quantity": quantity,
            "unitPrice": price,
            "totalPrice": price * quantity
          },
          "total": $sum(data.items.(price * quantity)),
          "tax": $sum(data.items.(price * quantity)) * 0.1,
          "grandTotal": $sum(data.items.(price * quantity)) * 1.1,
          "created": data.created,
          "processed": $now()
        }
      }
```

## Further Resources

- [EventTransform Overview and deployment patterns](./README.md)
- [JSONata Documentation](https://jsonata.org/documentation.html)
- [JSONata Exerciser](https://try.jsonata.org/)
- [CloudEvents Specification](https://github.com/cloudevents/spec)